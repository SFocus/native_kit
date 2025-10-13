import Flutter
import UIKit

public class NativeKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_kit", binaryMessenger: registrar.messenger())
    let instance = NativeKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Register NKTabBar channel and platform view factory (iOS 18.0+)
    if #available(iOS 18.0, *) {
      let navBarChannel = FlutterMethodChannel(name: "native_kit/tab_bar", binaryMessenger: registrar.messenger())
      let tabBarFactory = NKTabBarViewFactory(registrar: registrar, channel: navBarChannel)
      registrar.register(tabBarFactory, withId: "native_kit/tab_bar_view")
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Handle main channel methods
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
