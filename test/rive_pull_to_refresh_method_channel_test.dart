import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh_method_channel.dart';

void main() {
  MethodChannelRivePullToRefresh platform = MethodChannelRivePullToRefresh();
  const MethodChannel channel = MethodChannel('rive_pull_to_refresh');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
