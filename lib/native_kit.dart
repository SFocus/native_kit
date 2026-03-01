import 'native_kit_platform_interface.dart';

// Shared models
export 'src/models/nk_sf_symbol.dart';

// NKTabBar
export 'src/components/nk_tab_bar/nk_tab_bar.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_item.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_icon.dart';

// NKSwitch
export 'src/components/nk_switch/nk_switch.dart';

// NKSlider
export 'src/components/nk_slider/nk_slider.dart';

// NKButton
export 'src/components/nk_button/nk_button.dart';

// NKSegmentedControl
export 'src/components/nk_segmented_control/nk_segmented_control.dart';

// NKIcon
export 'src/components/nk_icon/nk_icon.dart';

// NKPopupMenu
export 'src/components/nk_popup_menu/nk_popup_menu.dart';
export 'src/components/nk_popup_menu/nk_popup_menu_item.dart';

class NativeKit {
  Future<String?> getPlatformVersion() {
    return NativeKitPlatform.instance.getPlatformVersion();
  }
}
