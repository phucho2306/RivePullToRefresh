import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class LiquidV1 extends StatefulWidget {
  static const String route = "/liquid_v1";
  const LiquidV1({super.key});

  @override
  State<LiquidV1> createState() => _MyAppState();
}

class _MyAppState extends State<LiquidV1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rivePullToRefreshController?.dispose();
    super.dispose();
  }

  SMINumber? _dy;
  SMINumber? _dx;
  SMITrigger? _bump;
  SMITrigger? _restart;

  final ScrollController _controller = ScrollController();
  RivePullToRefreshController? _rivePullToRefreshController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LiquidV1'),
        ),
        body: RivePullToRefresh(
          maxSizePaddingChildWhenPullDown: 65,
          timeResize: const Duration(milliseconds: 200),
          onInit: (controller) {
            _rivePullToRefreshController = controller;
          },

          //if the height of rive widget is larger try to upper this value
          kDragContainerExtentPercentage: 0.25,
          dragSizeFactorLimitMax: 1,
          sizeFactorLimitMin: 1,
          percentActiveBump: 0.5,
          style: RivePullToRefreshStyle.floating,
          curveMoveToPositionBumpStart: Curves.bounceOut,
          onMoveToPositionBumpStart: () {},
          bump: () async {
            //action start anim when stop Scrool
            _bump?.fire();

            //time play anim
            await Future.delayed(const Duration(seconds: 2));

            //close header
            await _rivePullToRefreshController!.close();

            //reset rive, design from rive.riv
            _restart?.fire();

            //call function onRefresh
            _rivePullToRefreshController!.onRefresh!();
          },
          callBackNumber: (number) {
            //anim when pull
            _dy?.value = number;
          },
          dxOfPointer: (value) {
            _dx?.value = value;
          },
          height: 138.5,
          riveWidget: RiveAnimation.asset(
            alignment: Alignment.bottomCenter,
            fit: BoxFit.cover,
            'assets/liquidv1.riv',
            onInit: _onRiveInit,
          ),

          controller: _controller,
          onRefresh: () async {},
          child: ListView.builder(
            physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            controller: _controller,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      index.toString(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, "StateMachine");
    artboard.addController(controller!);
    _bump = controller.findSMI("bump") as SMITrigger;
    _restart = controller.findSMI("restart") as SMITrigger;
    _dx = controller.findInput<double>("dx") as SMINumber;
    _dy = controller.findInput<double>("dy") as SMINumber;
  }
}
