import 'native_kit_platform_interface.dart';

// Shared models
export 'src/models/nk_sf_symbol.dart';
export 'src/models/nk_glass_style.dart';

// NKTabBar
export 'src/components/nk_tab_bar/nk_tab_bar.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_item.dart';
export 'src/components/nk_tab_bar/nk_tab_bar_icon.dart';

// NKSwitch
export 'src/components/nk_switch/nk_switch.dart';

// NKSlider
export 'src/components/nk_slider/nk_slider.dart';
export 'src/components/nk_slider/nk_slider_tick.dart';

// NKButton
export 'src/components/nk_button/nk_button.dart';

// NKSegmentedControl
export 'src/components/nk_segmented_control/nk_segmented_control.dart';

// NKIcon
export 'src/components/nk_icon/nk_icon.dart';

// NKPopupMenu
export 'src/components/nk_popup_menu/nk_popup_menu.dart';
export 'src/components/nk_popup_menu/nk_popup_menu_item.dart';

// NKGlassContainer
export 'src/components/nk_glass_container/nk_glass_container.dart';

// NKGlassCard
export 'src/components/nk_glass_card/nk_glass_card.dart';

// NKGlassButtonGroup
export 'src/components/nk_glass_button_group/nk_glass_button_group.dart';

// NKToast
export 'src/components/nk_toast/nk_toast.dart';

// NKToolbar
export 'src/components/nk_toolbar/nk_toolbar.dart';

// NKProgressView
export 'src/components/nk_progress_view/nk_progress_view.dart';

// NKDatePicker
export 'src/components/nk_date_picker/nk_date_picker.dart';

class NativeKit {
  Future<String?> getPlatformVersion() {
    return NativeKitPlatform.instance.getPlatformVersion();
  }
}
