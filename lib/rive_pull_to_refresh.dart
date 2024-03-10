// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//Im custom from Widget RefreshIndicator

import 'dart:async';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// The over-scroll distance that moves the indicator to its maximum
// displacement, as a percentage of the scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

// How much the scroll's drag gesture can overshoot the RivePullToRefresh's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

// When the scroll ends, the duration of the refresh indicator's animation
// to the RivePullToRefresh's displacement.
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

/// The signature for a function that's called when the user has dragged a
/// [RivePullToRefresh] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [RivePullToRefresh.onRefresh].
typedef RefreshCallback = Future<void> Function();

// The state machine moves through these modes only when the scrollable
// identified by scrollableKey has been scrolled to its min or max limit.
enum _RivePullToRefreshMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}

/// Used to configure how [RivePullToRefresh] can be triggered.
enum RivePullToRefreshTriggerMode {
  /// The indicator can be triggered regardless of the scroll position
  /// of the [Scrollable] when the drag starts.
  anywhere,

  /// The indicator can only be triggered if the [Scrollable] is at the edge
  /// when the drag starts.
  onEdge,
}

/// A widget that supports the Material "swipe to refresh" idiom.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ORApMlzwMdM}
///
/// When the child's [Scrollable] descendant overscrolls, an animated circular
/// progress indicator is faded into view. When the scroll ends, if the
/// indicator has been dragged far enough for it to become completely opaque,
/// the [onRefresh] callback is called. The callback is expected to update the
/// scrollable's contents and then complete the [Future] it returns. The refresh
/// indicator disappears after the callback's [Future] has completed.
///
/// The trigger mode is configured by [RivePullToRefresh.triggerMode].
///
/// {@tool dartpad}
/// This example shows how [RivePullToRefresh] can be triggered in different ways.
///
/// ** See code in examples/api/lib/material/refresh_indicator/refresh_indicator.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to trigger [RivePullToRefresh] in a nested scroll view using
/// the [notificationPredicate] property.
///
/// ** See code in examples/api/lib/material/refresh_indicator/refresh_indicator.1.dart **
/// {@end-tool}
///
/// ## Troubleshooting
///
/// ### Refresh indicator does not show up
///
/// The [RivePullToRefresh] will appear if its scrollable descendant can be
/// overscrolled, i.e. if the scrollable's content is bigger than its viewport.
/// To ensure that the [RivePullToRefresh] will always appear, even if the
/// scrollable's content fits within its viewport, set the scrollable's
/// [Scrollable.physics] property to [AlwaysScrollableScrollPhysics]:
///
/// ```dart
/// ListView(
///   physics: const AlwaysScrollableScrollPhysics(),
///   // ...
/// )
/// ```
///
/// A [RivePullToRefresh] can only be used with a vertical scroll view.
///
/// See also:
///
///  * <https://material.io/design/platform-guidance/android-swipe-to-refresh.html>
///  * [RivePullToRefreshState], can be used to programmatically show the refresh indicator.
///  * [RefreshProgressIndicator], widget used by [RivePullToRefresh] to show
///    the inner circular progress spinner during refreshes.
///  * [CupertinoSliverRefreshControl], an iOS equivalent of the pull-to-refresh pattern.
///    Must be used as a sliver inside a [CustomScrollView] instead of wrapping
///    around a [ScrollView] because it's a part of the scrollable instead of
///    being overlaid on top of it.
class RivePullToRefresh extends StatefulWidget {
  /// Creates a refresh indicator.
  ///
  /// The [onRefresh], [child], and [notificationPredicate] arguments must be
  /// non-null. The default

  const RivePullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.triggerMode = RivePullToRefreshTriggerMode.onEdge,
    this.scrollController,
    required this.riveWidget,
    required this.bump,
    required this.callBacknumber,
    this.animTime = const Duration(milliseconds: 2000),
    this.percentActiveBump = 30,
    this.style = RivePullToRefreshStyle.header,
  });

  final RivePullToRefreshStyle? style;

  /// The widget below this widget in the tree.
  ///
  /// The refresh indicator will be stacked on top of this child. The indicator
  /// will appear when child's Scrollable descendant is over-scrolled.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  final Widget child;

  /// [ScrollController] im using this to focus at possiton 0, list cant be wrong index when cancel refesh
  final ScrollController? scrollController;

  /// The offset where [RefreshProgressIndicator] starts to appear on drag start.
  ///
  /// Depending whether the indicator is showing on the top or bottom, the value
  /// of this variable controls how far from the parent's edge the progress
  /// indicator starts to appear. This may come in handy when, for example, the
  /// UI contains a top [Widget] which covers the parent's edge where the progress
  /// indicator would otherwise appear.

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. Set it to something
  /// else for more complicated layouts.
  final ScrollNotificationPredicate notificationPredicate;

  /// Defines how this [RivePullToRefresh] can be triggered when users overscroll.
  ///
  /// The [RivePullToRefresh] can be pulled out in two cases,
  /// 1, Keep dragging if the scrollable widget at the edge with zero scroll position
  ///    when the drag starts.
  /// 2, Keep dragging after overscroll occurs if the scrollable widget has
  ///    a non-zero scroll position when the drag starts.
  ///
  /// If this is [RivePullToRefreshTriggerMode.anywhere], both of the cases above can be triggered.
  ///
  /// If this is [RivePullToRefreshTriggerMode.onEdge], only case 1 can be triggered.
  ///
  /// Defaults to [RivePullToRefreshTriggerMode.onEdge].
  final RivePullToRefreshTriggerMode triggerMode;

  final Widget riveWidget;

  ///play anim before start Refresh
  final Function(bool) bump;

  ///anim when pull down or up. [callBacknumber] range 0 to 100
  final Function(double) callBacknumber;

  ///time of [bump] play success. Default animTime =  Duration(milliseconds: 2000)
  final Duration? animTime;

  ///when user scrool [percentActiveBump] percent. function [bump] will active. Default to 30%
  final int? percentActiveBump;
  @override
  RivePullToRefreshState createState() => RivePullToRefreshState();
}

/// Contains the state for a [RivePullToRefresh]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
class RivePullToRefreshState extends State<RivePullToRefresh> with TickerProviderStateMixin<RivePullToRefresh> {
  late AnimationController _positionController;
  late Animation<double> _positionFactor;

  _RivePullToRefreshMode? _mode;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;
  double? _oldPosition;
  static final Animatable<double> _kDragSizeFactorLimitTween = Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  bool _shouldStart(ScrollNotification notification) {
    // If the notification.dragDetails is null, this scroll is not triggered by
    // user dragging. It may be a result of ScrollController.jumpTo or ballistic scroll.
    // In this case, we don't want to trigger the refresh indicator.
    return ((notification is ScrollStartNotification && notification.dragDetails != null) ||
            (notification is ScrollUpdateNotification &&
                notification.dragDetails != null &&
                widget.triggerMode == RivePullToRefreshTriggerMode.anywhere)) &&
        ((notification.metrics.axisDirection == AxisDirection.up && notification.metrics.extentAfter == 0.0) ||
            (notification.metrics.axisDirection == AxisDirection.down && notification.metrics.extentBefore == 0.0)) &&
        _mode == null &&
        _start(notification.metrics.axisDirection);
  }

  double oldscrollDelta = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }
    if (_shouldStart(notification)) {
      setState(() {
        _mode = _RivePullToRefreshMode.drag;
      });
      return false;
    }
    bool? indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
      case AxisDirection.up:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _RivePullToRefreshMode.drag || _mode == _RivePullToRefreshMode.armed) {
        _dismiss(_RivePullToRefreshMode.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _RivePullToRefreshMode.drag ||
          _mode == _RivePullToRefreshMode.armed ||
          _mode == _RivePullToRefreshMode.canceled) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.scrollDelta!;
          _mode = _RivePullToRefreshMode.canceled;
        }

        _checkDragOffset(notification.metrics.viewportDimension);
      }
      if (_mode == _RivePullToRefreshMode.armed && notification.dragDetails == null) {
        // On iOS start the refresh when the Scrollable bounces back from the
        // overscroll (ScrollNotification indicating this don't have dragDetails
        // because the scroll activity is not directly triggered by a drag).
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _RivePullToRefreshMode.drag ||
          _mode == _RivePullToRefreshMode.armed ||
          _mode == _RivePullToRefreshMode.canceled) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.overscroll;
          if (_mode == _RivePullToRefreshMode.canceled) {
            _mode = _RivePullToRefreshMode.drag;
          }
        }

        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _RivePullToRefreshMode.armed:
          _show();
          break;
        case _RivePullToRefreshMode.drag:
        case _RivePullToRefreshMode.canceled:
          _dismiss(_RivePullToRefreshMode.canceled, jumpTo: _positionController.value > 0.0);
          break;
        case _RivePullToRefreshMode.done:
        case _RivePullToRefreshMode.refresh:
        case _RivePullToRefreshMode.snap:
        case null:
          // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleIndicatorNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) {
      return false;
    }
    if (_mode == _RivePullToRefreshMode.drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
      case AxisDirection.up:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _positionController.value = 0.0;
    widget.callBacknumber(0.0);
    _oldPosition = null;
    widget.bump(false);
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_mode == _RivePullToRefreshMode.drag ||
        _mode == _RivePullToRefreshMode.armed ||
        _mode == _RivePullToRefreshMode.canceled);

    double newValue = _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_oldPosition != null) {
      var value = clampDouble(_positionController.value - (_oldPosition! - newValue), 0.0, 1);
      widget.callBacknumber(value * 100);
      _positionController.value = value;
      // this triggers various rebuilds
    }
    _oldPosition = newValue;
    // if open 30% will start refresh
    if (_positionController.value > (widget.percentActiveBump! / 100)) {
      if (_mode == _RivePullToRefreshMode.drag) {
        _mode = _RivePullToRefreshMode.armed;
      }
    }
  }

  // Stop showing the refresh indicator.
  Future<void> _dismiss(_RivePullToRefreshMode newMode, {bool jumpTo = false}) async {
    await Future<void>.value();
    if (jumpTo) {
      widget.scrollController?.jumpTo(0);
    }
    await _positionController.animateTo(0.0, duration: _kIndicatorSnapDuration);

    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == _RivePullToRefreshMode.canceled || newMode == _RivePullToRefreshMode.done);
    setState(() {
      _mode = newMode;
    });

    if (mounted && _mode == newMode) {
      if (!jumpTo) {
        _dragOffset = null;
        _isIndicatorAtTop = null;
        setState(() {
          _mode = null;
        });
      }
    }
  }

  void _show() async {
    assert(_mode != _RivePullToRefreshMode.refresh);
    assert(_mode != _RivePullToRefreshMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _RivePullToRefreshMode.snap;
    // resize header
    await _positionController.animateTo(1.0 / _kDragSizeFactorLimit, duration: _kIndicatorSnapDuration);
    // play anim
    await widget.bump(true);
    // waiting play done anim
    await Future.delayed(widget.animTime!);
    // hide anim
    await _positionController.animateTo(0.0, duration: _kIndicatorSnapDuration);
    if (mounted && _mode == _RivePullToRefreshMode.snap) {
      setState(() {
        // Show the indeterminate progress indicator.
        _mode = _RivePullToRefreshMode.refresh;
      });

      final Future<void> refreshResult = widget.onRefresh();

      refreshResult.whenComplete(() {
        if (mounted && _mode == _RivePullToRefreshMode.refresh) {
          completer.complete();
          _dismiss(_RivePullToRefreshMode.done);
        }
      });
    }
  }

  /// Show the refresh indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [RivePullToRefresh] with a [GlobalKey<RivePullToRefreshState>]
  /// makes it possible to refer to the [RivePullToRefreshState].
  ///
  /// The future returned from this method completes when the
  /// [RivePullToRefresh.onRefresh] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].
  ///
  /// When initiated in this manner, the refresh indicator is independent of any
  /// actual scroll view. It defaults to showing the indicator at the top. To
  /// show it at the bottom, set `atTop` to false.
  Future<void> show({bool atTop = true}) {
    if (_mode != _RivePullToRefreshMode.refresh && _mode != _RivePullToRefreshMode.snap) {
      if (_mode == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );
    assert(() {
      if (_mode == null) {
        assert(_dragOffset == null);
        assert(_isIndicatorAtTop == null);
      } else {
        assert(_dragOffset != null);
        assert(_isIndicatorAtTop != null);
      }
      return true;
    }());

    switch (widget.style!) {
      case RivePullToRefreshStyle.header:
        return Column(
          children: <Widget>[
            Opacity(
              opacity: _mode != null ? 1 : 0,
              child: SizeTransition(
                axisAlignment: _isIndicatorAtTop == true ? 1.0 : -1.0,
                sizeFactor: _positionFactor, // this is what brings it down
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (context, _) {
                    return widget.riveWidget;
                  },
                ),
              ),
            ),
            Expanded(child: child),
          ],
        );
      case RivePullToRefreshStyle.header:
        return Stack(
          children: <Widget>[
            child,
            Opacity(
              opacity: _mode != null ? 1 : 0,
              child: SizeTransition(
                axisAlignment: _isIndicatorAtTop == true ? 1.0 : -1.0,
                sizeFactor: _positionFactor, // this is what brings it down
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (context, _) {
                    return widget.riveWidget;
                  },
                ),
              ),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }
}

enum RivePullToRefreshStyle { floating, header }
