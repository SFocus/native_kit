import Flutter
import UIKit

/// Factory for creating NKGlassContainer platform views (iOS 26.0+).
@available(iOS 26.0, *)
@objc public class NKGlassContainerViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar

    @objc public init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        NKGlassContainerPlatformView(
            frame: frame,
            viewId: viewId,
            arguments: args,
            registrar: registrar
        )
    }

    @objc public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View

@available(iOS 26.0, *)
final class NKGlassContainerPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let effectView: UIVisualEffectView

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/glass_container_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.effectView = UIVisualEffectView(frame: frame)
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)

        if let arguments = args as? [String: Any],
           let isDark = arguments["isDark"] as? Bool {
            effectView.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }

    func view() -> UIView { effectView }

    // MARK: - Configuration

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        let styleName = params["style"] as? String ?? "regular"
        let isInteractive = params["isInteractive"] as? Bool ?? false
        let cornerRadius = params["cornerRadius"] as? CGFloat
        let capsule = params["capsule"] as? Bool ?? false

        let tintColor: UIColor? = (params["tintColor"] as? Int64)
            .map { UIColor.fromARGB($0) }

        let glassStyle: UIGlassEffect.Style = styleName == "clear" ? .clear : .regular
        let effect = UIGlassEffect(style: glassStyle)
        effect.isInteractive = isInteractive
        if let tint = tintColor {
            effect.tintColor = tint
        }

        effectView.effect = effect
        NKGlassUtils.applyCornerConfiguration(
            to: effectView,
            cornerRadius: cornerRadius,
            capsule: capsule
        )
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS",
                       message: "Expected dictionary", details: nil))
                return
            }
            applyParams(args)
            result(nil)

        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let isDark = args["isDark"] as? Bool {
                effectView.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
