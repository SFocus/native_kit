library native_kit;

import 'native_kit_platform_interface.dart';

// NKTabBar component exports
export 'src/components/nk_tab_bar/nk_tab_bar.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_item.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_icon.dart';

class NativeKit {
  Future<String?> getPlatformVersion() {
    return NativeKitPlatform.instance.getPlatformVersion();
  }
}
