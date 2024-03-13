import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  SMIBool? _bump;
  SMINumber? _smiNumber;
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Expample App'),
      ),
      body: RivePullToRefresh(
        //if the height of rive widget is larger try to upper this value
        kDragContainerExtentPercentage: 0.4 * 3,
        kDragSizeFactorLimit: 1.5,
        percentActiveBump: 50,
        style: RivePullToRefreshStyle.header,
        bump: (value) {
          //action start anim after refresh call
          _bump?.value = value;
        },
        callBacknumber: (number) {
          //anim when pull
          _smiNumber?.value = number;
        },
        riveWidget: SizedBox(
          height: 500,
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

    _smiNumber = controller.findInput<double>("NumStart") as SMINumber;
  }
}
