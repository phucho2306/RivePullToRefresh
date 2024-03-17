import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class PullRflipid extends StatefulWidget {
  static const String route = "/pull_rf_lipid";
  const PullRflipid({super.key});

  @override
  State<PullRflipid> createState() => _MyAppState();
}

class _MyAppState extends State<PullRflipid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rivePullToRefreshController?.dispose();
    super.dispose();
  }

  SMIBool? _bump;
  SMINumber? _smiNumber;
  SMITrigger? _restart;
  final ScrollController _controller = ScrollController();
  RivePullToRefreshController? _rivePullToRefreshController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Lipid'),
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
          _bump?.value = true;

          //time play anim
          await Future.delayed(const Duration(seconds: 2));
          _bump?.value = false;

          await Future.delayed(const Duration(seconds: 2));
          //close header
          await _rivePullToRefreshController!.close();

          //reset rive, design from rive.riv

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
    final controller = StateMachineController.fromArtboard(artboard, "Motion");
    artboard.addController(controller!);

    _bump = controller.findInput<bool>("start") as SMIBool;
    _restart = controller.findInput<bool>("restart") as SMITrigger;
    _smiNumber = controller.findInput<double>("numDrag") as SMINumber;
  }
}
