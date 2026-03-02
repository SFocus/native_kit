import Flutter
import UIKit

/// Factory for creating NKSwitch platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKSwitchViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKSwitchPlatformView(
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

@available(iOS 18.0, *)
final class NKSwitchPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let uiSwitch: UISwitch

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/switch_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        self.uiSwitch = UISwitch()
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
        setupSwitch()
    }

    func view() -> UIView { container }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }

        uiSwitch.isOn = arguments["value"] as? Bool ?? false
        uiSwitch.isEnabled = arguments["enabled"] as? Bool ?? true
        applyColors(arguments)
    }

    private func applyColors(_ arguments: [String: Any]) {
        uiSwitch.onTintColor = nil
        uiSwitch.backgroundColor = .clear
        uiSwitch.layer.cornerRadius = 0
        uiSwitch.thumbTintColor = nil

        if let color = arguments["activeColor"] as? Int64 {
            uiSwitch.onTintColor = UIColor.fromARGB(color)
        }
        if let color = arguments["trackColor"] as? Int64 {
            uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2
            uiSwitch.backgroundColor = UIColor.fromARGB(color)
        }
        if let color = arguments["thumbColor"] as? Int64 {
            uiSwitch.thumbTintColor = UIColor.fromARGB(color)
        }
    }

    private func setupSwitch() {
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)

        container.addSubview(uiSwitch)
        NSLayoutConstraint.activate([
            uiSwitch.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            uiSwitch.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }

    @objc private func switchValueChanged() {
        channel.invokeMethod("onValueChanged", arguments: uiSwitch.isOn)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
            return
        }

        switch call.method {
        case "update":
            uiSwitch.setOn(args["value"] as? Bool ?? uiSwitch.isOn, animated: false)
            uiSwitch.isEnabled = args["enabled"] as? Bool ?? uiSwitch.isEnabled
            applyColors(args)
            result(nil)

        case "setValue":
            let value = args["value"] as? Bool ?? false
            let animated = args["animated"] as? Bool ?? true
            uiSwitch.setOn(value, animated: animated)
            result(nil)

        case "setEnabled":
            let enabled = args["enabled"] as? Bool ?? true
            uiSwitch.isEnabled = enabled
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
