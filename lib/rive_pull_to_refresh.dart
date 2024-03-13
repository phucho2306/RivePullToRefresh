import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RivePullToRefreshState { accept, cancel }

enum RivePullToRefreshStyle { header, floating }

const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

class RivePullToRefreshController {
  RivePullToRefreshController({
    Future<void> Function()? onRefreshI,
    ScrollController? controller,
    AnimationController? positionController,
  }) : super() {
    onRefresh = onRefreshI;
    _controller = controller;
    _positionController = positionController;
  }
  RivePullToRefreshState? _rivePullToRefreshState;

  Future<void> Function()? onRefresh;

  double? _oldValue;

  double _dragOffset = 0.0;

  ScrollController? _controller;

  AnimationController? _positionController;

  Future close({bool jumpTo = false}) async {
    await _positionController?.animateTo(0.0, duration: _kIndicatorScaleDuration);
    _oldValue = null;
    _dragOffset = 0.0;
    _rivePullToRefreshState = null;
    if (jumpTo) {
      _controller?.jumpTo(0);
    }
  }
}

class RivePullToRefresh extends StatefulWidget {
  const RivePullToRefresh(
      {required this.child,
      required this.riveWidget,
      required this.onRefresh,
      this.bump,
      this.callBacknumber,
      this.style = RivePullToRefreshStyle.header,
      this.controller,
      this.animTime = const Duration(milliseconds: 2000),
      this.percentActiveBump = 30,
      this.kDragSizeFactorLimit = 1.5,
      this.kDragContainerExtentPercentage = 0.25,
      required this.onInit,
      Key? key})
      : super(key: key);

  final Widget child;
  final void Function(RivePullToRefreshController) onInit;

  /// [kDragSizeFactorLimit]How much the scroll's drag gesture can overshoot the RefreshIndicator's
  final double kDragSizeFactorLimit;

  ///[kDragContainerExtentPercentage] The over-scroll distance that moves the indicator to its maximum
  final double kDragContainerExtentPercentage;

  ///[controller] to set position to 0.0 when client cancel refresh
  final ScrollController? controller;

  final RivePullToRefreshStyle style;
  final Function()? bump;

  ///[callBacknumber] value return range 0-100 when client scrool
  final Function(double)? callBacknumber;
  final Widget riveWidget;
  final Future<void> Function() onRefresh;

  ///Duration [animTime] time will play anim before close and call back onRefresh
  final Duration animTime;

  ///[percentActiveBump] value range 0 to 100.
  /// when user stop drang and value of if position(value range 0.0 to 1.0)* 100 > percentActiveBump refresh will start
  final double percentActiveBump;

  @override
  State<RivePullToRefresh> createState() => _RivePullToRefreshState();
}

class _RivePullToRefreshState extends State<RivePullToRefresh> with TickerProviderStateMixin<RivePullToRefresh> {
  late AnimationController _positionController;
  late Animation<double> _positionFactor;
  late Animatable<double> _kDragSizeFactorLimitTween;
  late RivePullToRefreshController _controller;
  Completer? completer;
  @override
  void initState() {
    super.initState();
    _kDragSizeFactorLimitTween = Tween<double>(begin: 0.0, end: widget.kDragSizeFactorLimit);
    if (widget.percentActiveBump > 100 || widget.percentActiveBump <= 0) {
      log("[percentActiveBump] not correct. this value range from 0 to 100");
      throw Error();
    }

    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _controller = RivePullToRefreshController(
        onRefreshI: widget.onRefresh, controller: widget.controller, positionController: _positionController);
    widget.onInit(_controller);
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  bool handleOnNotification(ScrollNotification notification) {
    if (completer != null) {
      return false;
    }
    if (notification is ScrollStartNotification && notification.metrics.pixels == 0) {
      _shouldStart = true;
    }
    if (notification.metrics.pixels > 0 && _controller._rivePullToRefreshState == null) {
      _shouldStart = false;
    }

    if (_controller._rivePullToRefreshState != null && _shouldStart == true) {
      // calculator position here
      if (notification is ScrollUpdateNotification) {
        _controller._dragOffset = _controller._dragOffset + notification.scrollDelta!;

        //When the user pulls up a little, it is still a accepted
        if (_positionController.value <= 0.95) {
          _controller._rivePullToRefreshState = RivePullToRefreshState.cancel;
        }
      }
      if (notification is OverscrollNotification) {
        _controller._dragOffset = _controller._dragOffset + notification.overscroll;
        if (_positionController.value > (widget.percentActiveBump / 100)) {
          _controller._rivePullToRefreshState = RivePullToRefreshState.accept;
        }
      }
      double newValue =
          (_controller._dragOffset) / (notification.metrics.viewportDimension * widget.kDragContainerExtentPercentage);
      if (_controller._oldValue != null) {
        var value = _positionController.value + (_controller._oldValue! - newValue);
        _positionController.value = clampDouble(value, 0.0, 1.0);
        widget.callBacknumber?.call(_positionController.value * 100);
      }
      _controller._oldValue = newValue;
    }
    if (notification is ScrollEndNotification) {
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
      await _positionController.animateTo(1 / widget.kDragSizeFactorLimit, duration: _kIndicatorScaleDuration);
      await widget.bump?.call();
    } else {
      await _controller.close(jumpTo: jumpTo);
    }
    completer!.complete();
    completer = null;
  }

  bool _shouldStart = true;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: handleOnNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          if (notification.depth != 0 || !notification.leading) {
            return false;
          }
          if (_controller._rivePullToRefreshState != null && _shouldStart) {
            notification.disallowIndicator();
          } else {
            if (_controller._rivePullToRefreshState == null) {
              // action first pull Overscroll to active refresh
              _controller._rivePullToRefreshState = RivePullToRefreshState.cancel;
              return true;
            }
          }

          return false;
        },
        child: widget.child,
      ),
    );
    Widget riveWidget = SizeTransition(
      axisAlignment: _controller._rivePullToRefreshState == null ? 1.0 : -1.0,
      sizeFactor: _positionFactor, // this is what brings it down
      child: AnimatedBuilder(
        animation: _positionController,
        builder: (BuildContext context, Widget? _) {
          return widget.riveWidget;
        },
      ),
    );

    if (widget.style == RivePullToRefreshStyle.floating) {
      return Stack(
        children: [
          child,
          Opacity(
            opacity: _controller._rivePullToRefreshState != null ? 0 : 1,
            child: riveWidget,
          ),
        ],
      );
    }
    return Column(
      children: [
        Opacity(
          opacity: _controller._rivePullToRefreshState != null ? 0 : 1,
          child: riveWidget,
        ),
        Expanded(
          child: child,
        )
      ],
    );
  }
}
