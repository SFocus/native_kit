import Flutter
import UIKit

public class NativeKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_kit", binaryMessenger: registrar.messenger())
    let instance = NativeKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    if #available(iOS 18.0, *) {
      // NKTabBar
      let tabBarFactory = NKTabBarViewFactory(registrar: registrar)
      registrar.register(tabBarFactory, withId: "native_kit/tab_bar_view")

      // NKSwitch
      let switchFactory = NKSwitchViewFactory(registrar: registrar)
      registrar.register(switchFactory, withId: "native_kit/switch_view")

      // NKSlider
      let sliderFactory = NKSliderViewFactory(registrar: registrar)
      registrar.register(sliderFactory, withId: "native_kit/slider_view")

      // NKButton
      let buttonFactory = NKButtonViewFactory(registrar: registrar)
      registrar.register(buttonFactory, withId: "native_kit/button_view")

      // NKSegmentedControl
      let segmentedControlFactory = NKSegmentedControlViewFactory(registrar: registrar)
      registrar.register(segmentedControlFactory, withId: "native_kit/segmented_control_view")

      // NKIcon
      let iconFactory = NKIconViewFactory(registrar: registrar)
      registrar.register(iconFactory, withId: "native_kit/icon_view")
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
