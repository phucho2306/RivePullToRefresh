import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class Planet extends StatefulWidget {
  static const String route = "/painet";
  const Planet({super.key});

  @override
  State<Planet> createState() => _MyAppState();
}

class _MyAppState extends State<Planet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rivePullToRefreshController?.dispose();
    super.dispose();
  }

  TextEditingController textEditingController = TextEditingController(text: "50");
  SMIBool? _bump;
  SMINumber? _smiNumber;
  final ScrollController _controller = ScrollController();
  RivePullToRefreshController? _rivePullToRefreshController;
  bool isFloatStyle = false;
  double paddingTop = 50;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Floating style"),
              Switch(
                value: isFloatStyle,
                onChanged: (value) {
                  isFloatStyle = value;
                  setState(() {});
                },
              ),
            ],
          ),
          if (isFloatStyle)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Max padding top when pull down"),
                SizedBox(
                  width: 30,
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: textEditingController,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        paddingTop = double.parse(value);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            )
        ],
      ),
      appBar: AppBar(
        title: const Text('Planet'),
      ),
      body: RivePullToRefresh(
        maxSizePaddingChildWhenPullDown: paddingTop,
        timeResize: const Duration(seconds: 1),
        onInit: (controller) {
          _rivePullToRefreshController = controller;
        },
        //if the height of rive widget is larger try to upper this value
        kDragContainerExtentPercentage: 0.25,

        percentActiveBump: 0.5,
        style: isFloatStyle ? RivePullToRefreshStyle.floating : RivePullToRefreshStyle.header,
        curveMoveToPositionBumpStart: Curves.bounceOut,
        onMoveToPositionBumpStart: () {
          _bump?.value = true;
        },
        bump: () async {
          //action start anim when stop Scrool

          //time play anim
          await Future.delayed(const Duration(seconds: 2));

          //close header
          await _rivePullToRefreshController!.close();

          //reset rive, design from rive.riv

          _bump?.value = false;
          _smiNumber?.value = 0;

          //call function onRefresh
          _rivePullToRefreshController!.onRefresh!();

          //TimeStartAnim
        },
        callBackNumber: (number) {
          //anim when pull
          _smiNumber?.value = number;
        },
        height: 100,

        riveWidget: SizedBox(
          child: RiveAnimation.asset(
            'assets/pullrf.riv',
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
    final controller = StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);

    _bump = controller.findInput<bool>("Active") as SMIBool;

    _smiNumber = controller.findInput<double>("dragNumber") as SMINumber;
  }
}
