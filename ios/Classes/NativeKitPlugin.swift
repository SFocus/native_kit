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
