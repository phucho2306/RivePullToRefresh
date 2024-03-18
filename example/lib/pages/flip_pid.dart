import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class FlipPid extends StatefulWidget {
  static const String route = "/flip_pid";
  const FlipPid({super.key});

  @override
  State<FlipPid> createState() => _MyAppState();
}

class _MyAppState extends State<FlipPid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rivePullToRefreshController?.dispose();
    super.dispose();
  }

  SMITrigger? _bump;
  SMITrigger? _restart;
  SMINumber? _smiNumber;
  final ScrollController _controller = ScrollController();
  RivePullToRefreshController? _rivePullToRefreshController;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Flip Pid'),
      ),
      body: RivePullToRefresh(
        timeResize: const Duration(milliseconds: 200),
        onInit: (controller) {
          _rivePullToRefreshController = controller;
        },

        //if the height of rive widget is larger try to upper this value
        kDragContainerExtentPercentage: 0.25,
        dragSizeFactorLimitMax: 1,
        sizeFactorLimitMin: 1,

        percentActiveBump: 50,
        style: RivePullToRefreshStyle.header,
        curveMoveToPositionBump: Curves.bounceOut,
        onMoveToPositionBump: () {},
        bump: () async {
          //action start anim when stop Scrool
          _bump?.fire();
          //time play anim
          await Future.delayed(const Duration(seconds: 1));

          _bump?.fire();

          await Future.delayed(const Duration(seconds: 1));

          //close header
          await _rivePullToRefreshController!.close();
          _smiNumber?.value = 0;
          _restart?.fire();

          //call function onRefresh
          _rivePullToRefreshController!.onRefresh!();

          //TimeStartAnim
        },
        callBacknumber: (number) {
          //anim when pull
          _smiNumber?.value = number;
        },
        riveWidget: SizedBox(
          height: 200,
          child: RiveAnimation.asset(
            fit: BoxFit.fitWidth,
            'assets/pullrflipid.riv',
            onInit: _onRiveInit,
          ),
        ),

        controller: _controller,
        onRefresh: () async {},
        child: ListView.builder(
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
    ));
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, "numberSimulation");
    artboard.addController(controller!);
    _bump = controller.findSMI("advance") as SMITrigger;
    _restart = controller.findSMI("restart") as SMITrigger;
    _smiNumber = controller.findInput<double>("pull") as SMINumber;
  }
}
