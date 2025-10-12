
import 'native_kit_platform_interface.dart';

class NativeKit {
  Future<String?> getPlatformVersion() {
    return NativeKitPlatform.instance.getPlatformVersion();
  }
}
