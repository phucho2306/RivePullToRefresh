import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class SpaceReload extends StatefulWidget {
  static const String route = "/space_reload";
  const SpaceReload({super.key});

  @override
  State<SpaceReload> createState() => _MyAppState();
}

class _MyAppState extends State<SpaceReload> {
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
        title: const Text('SpaceReload'),
      ),
      body: RivePullToRefresh(
        timeResize: const Duration(milliseconds: 100),
        onInit: (controller) {
          _rivePullToRefreshController = controller;
        },

        //if the height of rive widget is larger try to upper this value
        kDragContainerExtentPercentage: 0.5,
        dragSizeFactorLimitMax: 1,
        sizeFactorLimitMin: 0.9,

        percentActiveBump: 0.5,
        openHeaderStyle: RiveOpenHeaderStyle.behide,
        curveMoveToPositionBumpStart: Curves.linear,
        onMoveToPositionBumpStart: () {},
        bump: () async {
          //action start anim when stop Scrool
          _bump?.value = true;

          //time play anim
          await Future.delayed(const Duration(milliseconds: 2000));

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
        height: 230,
        riveWidget: RiveAnimation.asset(
          alignment: Alignment.center,
          fit: BoxFit.cover,
          'assets/space_reload.riv',
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
    final controller = StateMachineController.fromArtboard(artboard, "Reload");
    artboard.addController(controller!);

    _bump = controller.findInput<bool>("Start") as SMIBool;

    _smiNumber = controller.findInput<double>("Pull Amount") as SMINumber;
  }
}
