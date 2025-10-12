import 'package:flutter_test/flutter_test.dart';
import 'package:native_kit/native_kit.dart';
import 'package:native_kit/native_kit_platform_interface.dart';
import 'package:native_kit/native_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeKitPlatform
    with MockPlatformInterfaceMixin
    implements NativeKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeKitPlatform initialPlatform = NativeKitPlatform.instance;

  test('$MethodChannelNativeKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeKit>());
  });

  test('getPlatformVersion', () async {
    NativeKit nativeKitPlugin = NativeKit();
    MockNativeKitPlatform fakePlatform = MockNativeKitPlatform();
    NativeKitPlatform.instance = fakePlatform;

    expect(await nativeKitPlugin.getPlatformVersion(), '42');
  });
}
