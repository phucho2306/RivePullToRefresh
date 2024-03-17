import 'package:flutter/material.dart';
import 'package:rive_pull_to_refresh_example/pages/gif.dart';
import 'package:rive_pull_to_refresh_example/pages/liquid.dart';
import 'package:rive_pull_to_refresh_example/pages/planet.dart';
import 'package:rive_pull_to_refresh_example/pages/pull_rf_lipid.dart';
import 'package:rive_pull_to_refresh_example/pages/space_reload.dart';

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
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        Planet.route: (BuildContext context) {
          return const Planet();
        },
        Liquid.route: (BuildContext context) {
          return const Liquid();
        },
        MainPage.route: (BuildContext context) {
          return const MainPage();
        },
        Gif.route: (BuildContext context) {
          return const Gif();
        },
        SpaceReload.route: (BuildContext context) {
          return const SpaceReload();
        },
        PullRflipid.route: (BuildContext context) {
          return const PullRflipid();
        },
      },
    );
  }
}

class MainPage extends StatefulWidget {
  static const String route = "/";
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rive Pull To Refresh"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppButton(
              title: "Planet",
              onPress: () => Navigator.pushNamed(context, Planet.route),
            ),
            AppButton(
              title: "Lipuid",
              onPress: () => Navigator.pushNamed(
                context,
                Liquid.route,
              ),
            ),
            AppButton(
              title: "Gif",
              onPress: () => Navigator.pushNamed(
                context,
                Gif.route,
              ),
            ),
            AppButton(
              title: "Space",
              onPress: () => Navigator.pushNamed(
                context,
                SpaceReload.route,
              ),
            ),
            AppButton(
              title: "Lipid",
              onPress: () => Navigator.pushNamed(
                context,
                PullRflipid.route,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({this.title = "", this.onPress, super.key});
  final String title;
  final Function()? onPress;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        color: Colors.amber,
        margin: const EdgeInsets.only(bottom: 15),
        height: 50,
        width: double.infinity,
        child: Center(child: Text(title)),
      ),
    );
  }
}
