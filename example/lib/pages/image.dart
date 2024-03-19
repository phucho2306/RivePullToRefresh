import 'package:flutter/material.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';

class ImageR extends StatefulWidget {
  static const String route = "/image";
  const ImageR({super.key});

  @override
  State<ImageR> createState() => _MyAppState();
}

class _MyAppState extends State<ImageR> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _rivePullToRefreshController?.dispose();
    super.dispose();
  }

  double size = 200;
  RivePullToRefreshController? _rivePullToRefreshController;
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('ImageR'),
      ),
      body: RivePullToRefresh(
        maxSizePaddingChildWhenPullDown: size,
        timeResize: const Duration(milliseconds: 100),
        onInit: (controller) {
          _rivePullToRefreshController = controller;
        },

        //if the height of rive widget is larger try to upper this value
        kDragContainerExtentPercentage: 0.45,
        dragSizeFactorLimitMax: 1,
        sizeFactorLimitMin: 0.8,
        percentActiveBump: 0.5,
        style: RivePullToRefreshStyle.floating,
        curveMoveToPositionBumpStart: Curves.bounceOut,
        onMoveToPositionBumpStart: () {},
        bump: () async {
          //time play anim
          await Future.delayed(const Duration(seconds: 2));

          //close header
          await _rivePullToRefreshController!.close();

          //call function onRefresh
          _rivePullToRefreshController!.onRefresh!();

          //TimeStartAnim
        },
        callBacknumber: (number) {
          //anim when pull
        },
        height: size,
        riveWidget: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.network(
                  fit: BoxFit.cover,
                  "https://storage.googleapis.com/cms-storage-bucket/images/Cupid_Dash_BlueBG.width-635.png"),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.only(top: 45),
                  child: RefreshProgressIndicator()),
            ),
          ],
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
}
