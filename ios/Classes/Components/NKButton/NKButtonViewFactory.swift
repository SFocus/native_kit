import Flutter
import UIKit

/// Factory for creating NKButton platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKButtonViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKButtonPlatformView(
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
final class NKButtonPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var button: UIButton!
    private var currentStyle: String = "filled"
    private var tintColor: UIColor?
    private var textStyleDict: [String: Any]?
    private var cornerRadius: CGFloat?
    private var heightConstraint: NSLayoutConstraint?

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/button_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        self.container.backgroundColor = .clear
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
    }

    func view() -> UIView { container }

    // MARK: - Configuration

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }

        let label = arguments["label"] as? String
        let iconData = arguments["icon"] as? [String: Any]
        let styleName = arguments["style"] as? String ?? "filled"
        let enabled = arguments["enabled"] as? Bool ?? true
        let height = arguments["height"] as? CGFloat ?? 44.0

        if let colorValue = arguments["tintColor"] as? Int64 {
            self.tintColor = UIColor.fromARGB(colorValue)
        }

        self.currentStyle = styleName

        // Create button with configuration
        var configuration = Self.makeConfiguration(for: styleName)

        if let label = label {
            configuration.title = label
        }

        if let iconData = iconData,
           let image = NKSymbolUtils.createImageFromSource(iconData) {
            configuration.image = image
            configuration.imagePadding = label != nil ? 6 : 0
        }

        if let tintColor = self.tintColor {
            configuration.baseForegroundColor = tintColor
        }

        // Text style
        self.textStyleDict = arguments["textStyle"] as? [String: Any]
        applyTextStyle(to: &configuration)

        // Corner radius
        self.cornerRadius = arguments["cornerRadius"] as? CGFloat
        applyCornerRadius(to: &configuration, style: styleName)

        button = UIButton(configuration: configuration)
        button.isEnabled = enabled
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        let hc = button.heightAnchor.constraint(equalToConstant: height)
        heightConstraint = hc

        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            hc,
        ])
    }

    // MARK: - Button Action

    @objc private func buttonPressed() {
        channel.invokeMethod("onPressed", arguments: nil)
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
            return
        }

        switch call.method {
        case "update":
            let label = args["label"] as? String
            let iconData = args["icon"] as? [String: Any]
            let styleName = args["style"] as? String ?? currentStyle
            let enabled = args["enabled"] as? Bool ?? true
            let height = args["height"] as? CGFloat ?? 44.0

            if let colorValue = args["tintColor"] as? Int64 {
                self.tintColor = UIColor.fromARGB(colorValue)
            } else {
                self.tintColor = nil
            }

            self.textStyleDict = args["textStyle"] as? [String: Any]
            self.cornerRadius = args["cornerRadius"] as? CGFloat

            var configuration: UIButton.Configuration
            if styleName != currentStyle {
                currentStyle = styleName
                configuration = Self.makeConfiguration(for: styleName)
            } else {
                configuration = button.configuration ?? Self.makeConfiguration(for: styleName)
            }

            configuration.title = label
            if let iconData = iconData,
               let image = NKSymbolUtils.createImageFromSource(iconData) {
                configuration.image = image
                configuration.imagePadding = label != nil ? 6 : 0
            } else {
                configuration.image = nil
                configuration.imagePadding = 0
            }
            if let tintColor = self.tintColor {
                configuration.baseForegroundColor = tintColor
            } else {
                configuration.baseForegroundColor = nil
            }
            applyTextStyle(to: &configuration)
            applyCornerRadius(to: &configuration, style: styleName)
            button.configuration = configuration
            button.isEnabled = enabled
            heightConstraint?.constant = height
            result(nil)

        case "setEnabled":
            guard let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected 'enabled' bool", details: nil))
                return
            }
            button.isEnabled = enabled
            result(nil)

        case "setLabel":
            let label = args["label"] as? String
            button.configuration?.title = label
            result(nil)

        case "setStyle":
            guard let styleName = args["style"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected 'style' string", details: nil))
                return
            }
            currentStyle = styleName
            // Preserve current title and image
            let title = button.configuration?.title
            let image = button.configuration?.image
            let imagePadding = button.configuration?.imagePadding ?? 0

            var newConfig = Self.makeConfiguration(for: styleName)
            newConfig.title = title
            newConfig.image = image
            newConfig.imagePadding = imagePadding

            if let tintColor = self.tintColor {
                newConfig.baseForegroundColor = tintColor
            }

            applyTextStyle(to: &newConfig)
            applyCornerRadius(to: &newConfig, style: styleName)

            button.configuration = newConfig
            result(nil)

        case "updateStyling":
            self.textStyleDict = args["textStyle"] as? [String: Any]
            if let cr = args["cornerRadius"] as? CGFloat {
                self.cornerRadius = cr
            }

            if var config = button.configuration {
                applyTextStyle(to: &config)
                applyCornerRadius(to: &config, style: currentStyle)
                button.configuration = config
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers

    private func applyCornerRadius(to configuration: inout UIButton.Configuration, style: String) {
        guard let cornerRadius = self.cornerRadius else { return }
        if #available(iOS 26.0, *) {
            // On iOS 26+, avoid mutating configuration.background for non-glass
            // styles — it prevents the automatic liquid glass treatment.
            let glassStyles: Set<String> = ["glass", "clearGlass", "prominentGlass", "prominentClearGlass"]
            if glassStyles.contains(style) {
                configuration.background.cornerRadius = cornerRadius
            }
        } else {
            configuration.background.cornerRadius = cornerRadius
        }
    }

    private func applyTextStyle(to configuration: inout UIButton.Configuration) {
        if let font = NKFontUtils.font(from: textStyleDict) {
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
        }
    }

    private static func makeConfiguration(for styleName: String) -> UIButton.Configuration {
        switch styleName {
        case "plain":
            return .plain()
        case "gray":
            return .gray()
        case "tinted":
            return .tinted()
        case "bordered":
            return .bordered()
        case "borderedProminent":
            return .borderedProminent()
        case "filled":
            return .filled()
        case "glass":
            if #available(iOS 26.0, *) {
                return .glass()
            }
            return .bordered()
        case "clearGlass":
            if #available(iOS 26.0, *) {
                return .clearGlass()
            }
            return .plain()
        case "prominentGlass":
            if #available(iOS 26.0, *) {
                return .prominentGlass()
            }
            return .borderedProminent()
        case "prominentClearGlass":
            if #available(iOS 26.0, *) {
                return .prominentClearGlass()
            }
            return .filled()
        default:
            return .filled()
        }
    }
}
