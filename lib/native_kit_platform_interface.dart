import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_kit_method_channel.dart';

abstract class NativeKitPlatform extends PlatformInterface {
  /// Constructs a NativeKitPlatform.
  NativeKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeKitPlatform _instance = MethodChannelNativeKit();

  /// The default instance of [NativeKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeKit].
  static NativeKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeKitPlatform] when
  /// they register themselves.
  static set instance(NativeKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
