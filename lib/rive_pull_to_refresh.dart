import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RivePullToRefreshState { accept, cancel }

enum RivePullToRefreshStyle { header, floating }

enum RiveOpenHeaderStyle { moveDown, behide }

enum Side { top, bottom }

class RivePullToRefreshController {
  RivePullToRefreshController({
    Future<void> Function()? onRefreshI,
    ScrollController? controller,
    AnimationController? positionController,
    Side? side,
  }) : super() {
    onRefresh = onRefreshI;
    _controller = controller;
    _positionController = positionController;
    _side = side;
  }
  RivePullToRefreshState? _rivePullToRefreshState;

  ///[onRefresh] You can proactively call the refresh function where you want, after resizing or just finishing playing a certain animation.
  Future<void> Function()? onRefresh;

  double? _oldValue;

  double _dragOffset = 0.0;

  ScrollController? _controller;

  AnimationController? _positionController;

  Side? _side;

  ///call [close] when you want hide widget refresh, curve is animation close.
  Future close({
    Duration? durationClose = const Duration(
      milliseconds: 200,
    ),
    Curve? curve,
  }) async {
    await _close(
        jumpTo: false, durationClose: durationClose, curve: curve, side: _side);
  }

  Future _close({
    bool jumpTo = false,
    Duration? durationClose = const Duration(milliseconds: 200),
    Curve? curve,
    Side? side,
  }) async {
    await _positionController?.animateTo(
      0.0,
      duration: durationClose,
      curve: curve ?? Curves.linear,
    );
    _oldValue = null;
    _dragOffset = 0.0;
    _rivePullToRefreshState = null;
    if (jumpTo) {
      if (side == Side.top) {
        _controller?.jumpTo(0);
      }
    }
  }

  double? get getPositionValue => _positionController?.value;

  void dispose() {
    _positionController?.dispose();
    _positionController = null;
  }
}

class RivePullToRefresh extends StatefulWidget {
  const RivePullToRefresh(
      {required this.onRefresh,
      required this.onInit,
      required this.riveWidget,
      this.child,
      this.children,
      required this.height,
      this.dxOfPointer,
      this.callBackNumber,
      this.bump,
      this.style = RivePullToRefreshStyle.header,
      this.controller,
      this.percentActiveBump = 0.3,
      this.dragSizeFactorLimitMax = 1.5,
      this.sizeFactorLimitMin = 1 / 1.5,
      this.kDragContainerExtentPercentage = 0.25,
      this.timeResize = const Duration(milliseconds: 200),
      this.onMoveToPositionBumpStart,
      this.curveMoveToPositionBumpStart = Curves.linear,
      this.maxSizePaddingChildWhenPullDown = 0,
      this.openHeaderStyle = RiveOpenHeaderStyle.moveDown,
      this.side = Side.top,
      Key? key})
      : super(key: key);

  final List<Widget>? children;

  final Widget? child;

  ///[_side] refresh widget will show in top or bottom, default is top.
  final Side side;

  ///[maxSizePaddingChildWhenPullDown] only avaible if RivePullToRefreshStyle is floating.
  final double maxSizePaddingChildWhenPullDown;
  final void Function(RivePullToRefreshController) onInit;

  ///[dragSizeFactorLimitMax] How much the scroll's drag gesture can overshoot the RefreshIndicator.
  final double dragSizeFactorLimitMax;

  ///[sizeFactorLimitMin] value range 0.0 to [dragSizeFactorLimitMax]
  final double sizeFactorLimitMin;

  ///[kDragContainerExtentPercentage] The over-scroll distance that moves the indicator to its maximum.
  final double kDragContainerExtentPercentage;

  final ScrollController? controller;

  ///[style] style floating and header, default is header.

  ///[RivePullToRefreshStyle.floating] type make refresh widget in behind list.

  ///[RivePullToRefreshStyle.header] type make refresh widget move down.

  final RivePullToRefreshStyle style;

  ///[bump] call when start animation loading
  final Function()? bump;

  ///[callBackNumber] dy percentage of pointer on screen. value return range 0-100 when client scrool down or up.
  final Function(double)? callBackNumber;
  final Widget riveWidget;
  final Future<void> Function() onRefresh;

  ///[percentActiveBump] 0.0 > percentActiveBump  <= 1.0.
  ///when user stop drang and value of [_positionController] > [percentActiveBump] refresh will call.
  final double percentActiveBump;

  ///[timeResize] is Duration moving to [sizeFactorLimitMin].
  final Duration timeResize;

  ///[onMoveToPositionBumpStart] call when start moving to [sizeFactorLimitMin].
  final Function? onMoveToPositionBumpStart;

  ///[curveMoveToPositionBumpStart] An parametric animation easing curve when moving to [sizeFactorLimitMin].
  final Curve? curveMoveToPositionBumpStart;

  ///[height] of refresh widget.
  final double height;

  ///[openHeaderStyle] default is moveDown.

  ///[RiveOpenHeaderStyle.moveDown] refresh widget will move on top to down.

  ///[RiveOpenHeaderStyle.behide] refresh widget will open on center header.

  final RiveOpenHeaderStyle? openHeaderStyle;

  ///[dxOfPointer] dx percentage of pointer on screen. value return range 0-100 when client scrool left or right.
  final Function(double)? dxOfPointer;
  @override
  State<RivePullToRefresh> createState() => _RivePullToRefreshState();
}

class _RivePullToRefreshState extends State<RivePullToRefresh>
    with TickerProviderStateMixin<RivePullToRefresh> {
  late AnimationController _positionController;
  late Animation<double> _positionFactor;
  late Animatable<double> _kDragSizeFactorLimitTween;
  late RivePullToRefreshController _controller;
  late double width;
  Completer? completer;
  late Side _side;
  @override
  void initState() {
    super.initState();
    if (widget.child == null && widget.children == null) {
      throw ("child or children can't be null");
    }
    if (widget.child != null && widget.children != null) {
      throw ("Don't use both, choose either 'child' or 'children'.");
    }

    _side = widget.side;

    _kDragSizeFactorLimitTween =
        Tween<double>(begin: 0.0, end: widget.dragSizeFactorLimitMax);
    if (widget.percentActiveBump <= 0.0 || widget.percentActiveBump > 1.0) {
      log("[percentActiveBump] not correct. this value range from 0 to 100");
      throw Error();
    }

    if (_side == Side.bottom) {
      _axisAlignment = -1.0;
    }
    if (widget.openHeaderStyle == RiveOpenHeaderStyle.behide) {
      _axisAlignment = 0.0;
    }
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _controller = RivePullToRefreshController(
        onRefreshI: widget.onRefresh,
        controller: widget.controller,
        positionController: _positionController,
        side: _side);
    _controller._controller ??= ScrollController();

    widget.onInit(_controller);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (completer != null) {
      return false;
    }

    if (notification is ScrollStartNotification &&
        (widget.side == Side.top
            ? notification.metrics.pixels == 0
            : notification.metrics.pixels ==
                notification.metrics.maxScrollExtent)) {
      _shouldStart.value = true;
    }
    if ((widget.side == Side.top
            ? notification.metrics.pixels > 0
            : notification.metrics.pixels <
                notification.metrics.maxScrollExtent) &&
        _controller._rivePullToRefreshState == null) {
      _shouldStart.value = false;
    }
    if (Platform.isIOS && notification is OverscrollNotification) {
      if (!(_controller._rivePullToRefreshState == null &&
          !_shouldStart.value)) {
        // action first pull Overscroll to active refresh
        _controller._rivePullToRefreshState = RivePullToRefreshState.cancel;
      }
    }

    if ((notification is ScrollUpdateNotification ||
            notification is OverscrollNotification) &&
        _controller._rivePullToRefreshState != null &&
        _shouldStart.value == true) {
      // calculator position here
      if (notification is ScrollUpdateNotification) {
        if (notification.dragDetails != null) {
          widget.dxOfPointer?.call(
              (notification.dragDetails!.localPosition.dx / width) * 100);
        }
        if (_side == Side.top) {
          _controller._dragOffset =
              _controller._dragOffset + notification.scrollDelta!;
        } else {
          _controller._dragOffset =
              _controller._dragOffset - notification.scrollDelta!;
        }
        //When the user pulls up a little, refresh will be accepted
        if (_positionController.value <= 0.95) {
          _controller._rivePullToRefreshState = RivePullToRefreshState.cancel;
        }
      }
      if (notification is OverscrollNotification) {
        if (notification.dragDetails != null) {
          widget.dxOfPointer?.call(
              (notification.dragDetails!.localPosition.dx / width) * 100);
        }

        if (_side == Side.top) {
          _controller._dragOffset =
              _controller._dragOffset + notification.overscroll;
        } else {
          _controller._dragOffset =
              _controller._dragOffset - notification.overscroll;
        }
        if (_positionController.value >= (widget.percentActiveBump)) {
          _controller._rivePullToRefreshState = RivePullToRefreshState.accept;
        }
      }
      double newValue = (_controller._dragOffset) /
          (notification.metrics.viewportDimension *
              widget.kDragContainerExtentPercentage);
      if (_controller._oldValue != null) {
        double value =
            _positionController.value + (_controller._oldValue! - newValue);

        _positionController.value = clampDouble(value, 0, 1);
        widget.callBackNumber?.call(_positionController.value * 100);
      }

      _controller._oldValue = newValue;
    } else if (notification is ScrollEndNotification) {
      if (_controller._rivePullToRefreshState == null) {
        return false;
      }
      checkScroolEnd(jumpTo: _positionController.value > 0);
    }

    return true;
  }

  void checkScroolEnd({bool jumpTo = false}) async {
    completer = Completer();
    if (_controller._rivePullToRefreshState == RivePullToRefreshState.accept) {
      widget.onMoveToPositionBumpStart?.call();
      await _positionController.animateTo(widget.sizeFactorLimitMin,
          duration: widget.timeResize,
          curve: widget.curveMoveToPositionBumpStart!);
      await widget.bump?.call();
    } else {
      await _controller._close(jumpTo: jumpTo);
    }
    completer!.complete();
    completer = null;
  }

  final ValueNotifier<bool> _shouldStart = ValueNotifier<bool>(true);

  double _axisAlignment = 1.0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    assert(debugCheckHasMaterialLocalizations(context));

    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        //only suport android
        onNotification: (notification) {
          if ((notification.depth != 0 ||
              (widget.side == Side.top
                  ? !notification.leading
                  : notification.leading))) {
            return false;
          }
          if (_controller._rivePullToRefreshState != null &&
              _shouldStart.value) {
            notification.disallowIndicator();
          } else {
            if (_controller._rivePullToRefreshState == null) {
              // action first pull Overscroll to active refresh
              _controller._rivePullToRefreshState =
                  RivePullToRefreshState.cancel;
              return true;
            }
          }

          return false;
        },
        child: widget.child ??
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              controller: _controller._controller,
              child: Column(
                children: widget.children!,
              ),
            ),
      ),
    );

    Widget riveWidget = SizeTransition(
      axisAlignment:
          _controller._rivePullToRefreshState == null ? _axisAlignment : -1.0,
      sizeFactor: _positionFactor, // this is what brings it down
      child: AnimatedBuilder(
        animation: _positionController,
        builder: (BuildContext context, Widget? _) {
          return SizedBox(height: widget.height, child: widget.riveWidget);
        },
      ),
    );

    if (widget.style == RivePullToRefreshStyle.floating) {
      return Stack(
        children: [
          widget.maxSizePaddingChildWhenPullDown == 0
              ? child
              : Column(
                  children: [
                    if (_side == Side.top)
                      SizeTransition(
                        axisAlignment:
                            _controller._rivePullToRefreshState == null
                                ? _axisAlignment
                                : -1.0,
                        sizeFactor:
                            _positionFactor, // this is what brings it down
                        child: AnimatedBuilder(
                          animation: _positionController,
                          builder: (BuildContext context, Widget? _) {
                            return SizedBox(
                              height: widget.maxSizePaddingChildWhenPullDown,
                            );
                          },
                        ),
                      ),
                    Expanded(child: child),
                    if (_side == Side.bottom)
                      SizeTransition(
                        axisAlignment:
                            _controller._rivePullToRefreshState == null
                                ? _axisAlignment
                                : -1.0,
                        sizeFactor:
                            _positionFactor, // this is what brings it down
                        child: AnimatedBuilder(
                          animation: _positionController,
                          builder: (BuildContext context, Widget? _) {
                            return SizedBox(
                              height: widget.maxSizePaddingChildWhenPullDown,
                            );
                          },
                        ),
                      ),
                  ],
                ),
          Opacity(
            opacity: _controller._rivePullToRefreshState != null ? 0 : 1,
            child: Align(
              alignment: _side == Side.top
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: riveWidget,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        if (_side == Side.top)
          Opacity(
            opacity: _controller._rivePullToRefreshState != null ? 0 : 1,
            child: riveWidget,
          ),
        Expanded(
          child: child,
        ),
        if (_side == Side.bottom)
          Opacity(
            opacity: _controller._rivePullToRefreshState != null ? 0 : 1,
            child: riveWidget,
          ),
      ],
    );
  }
}
