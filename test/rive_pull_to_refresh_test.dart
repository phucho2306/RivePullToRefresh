import 'package:flutter_test/flutter_test.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh_platform_interface.dart';
import 'package:rive_pull_to_refresh/rive_pull_to_refresh_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRivePullToRefreshPlatform
    with MockPlatformInterfaceMixin
    implements RivePullToRefreshPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RivePullToRefreshPlatform initialPlatform = RivePullToRefreshPlatform.instance;

  test('$MethodChannelRivePullToRefresh is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRivePullToRefresh>());
  });

  test('getPlatformVersion', () async {
    RivePullToRefresh rivePullToRefreshPlugin = RivePullToRefresh();
    MockRivePullToRefreshPlatform fakePlatform = MockRivePullToRefreshPlatform();
    RivePullToRefreshPlatform.instance = fakePlatform;

    expect(await rivePullToRefreshPlugin.getPlatformVersion(), '42');
  });
}
