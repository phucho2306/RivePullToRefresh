import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class Liquid extends StatefulWidget {
  static const String route = "/liquid";
  const Liquid({super.key});

  @override
  State<Liquid> createState() => _MyAppState();
}

class _MyAppState extends State<Liquid> {
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
  final ScrollController _controller = ScrollController();
  RivePullToRefreshController? _rivePullToRefreshController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Liquid'),
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
          _bump?.value = true;

          //time play anim
          await Future.delayed(const Duration(seconds: 2));

          //close header
          await _rivePullToRefreshController!.close();

          //reset rive, design from rive.riv

          _bump?.value = false;

          //call function onRefresh
          _rivePullToRefreshController!.onRefresh!();

          //TimeStartAnim
        },
        callBackNumber: (number) {
          //anim when pull
          _smiNumber?.value = number;
        },
        height: 120,
        riveWidget: RiveAnimation.asset(
          fit: BoxFit.cover,
          'assets/liquid.riv',
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
    ));
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);

    _bump = controller.findInput<bool>("play") as SMIBool;

    _smiNumber = controller.findInput<double>("drangNumber") as SMINumber;
  }
}
