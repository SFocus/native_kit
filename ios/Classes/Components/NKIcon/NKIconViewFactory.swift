import Flutter
import UIKit

/// Factory for creating NKIcon platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKIconViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKIconPlatformView(
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
final class NKIconPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let imageView: UIImageView

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/icon_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.imageView = UIImageView(frame: frame)
        self.imageView.contentMode = .scaleAspectFit
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)

        if let arguments = args as? [String: Any],
           let isDark = arguments["isDark"] as? Bool {
            imageView.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }

    func view() -> UIView { imageView }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        guard let sourceDict = params["source"] as? [String: Any],
              let type = sourceDict["type"] as? String else {
            return
        }

        // For image_data, create UIImage directly (no rendering modes)
        if type == "image_data" {
            if let image = NKSymbolUtils.createImageFromSource(sourceDict) {
                imageView.image = image
            }
            return
        }

        // SF Symbol path — full rendering mode support
        guard let parsed = NKSymbolUtils.parseIcon(from: sourceDict) else { return }

        let pointSize = params["size"] as? Double ?? 24.0
        let modeString = params["mode"] as? String ?? "monochrome"

        // Parse colors
        let primaryColor: UIColor? = (params["color"] as? Int64).map { UIColor.fromARGB($0) }
        let secondaryColor: UIColor? = (params["secondaryColor"] as? Int64).map { UIColor.fromARGB($0) }
        let tertiaryColor: UIColor? = (params["tertiaryColor"] as? Int64).map { UIColor.fromARGB($0) }

        // Build base symbol configuration from NKSymbolUtils (weight, scale)
        var symbolConfig = UIImage.SymbolConfiguration.unspecified

        if let configDict = parsed.config {
            if let weightStr = configDict["weight"] as? String {
                symbolConfig = symbolConfig.applying(
                    UIImage.SymbolConfiguration(weight: mapWeight(weightStr))
                )
            }
            if let scaleStr = configDict["scale"] as? String {
                symbolConfig = symbolConfig.applying(
                    UIImage.SymbolConfiguration(scale: mapScale(scaleStr))
                )
            }
        }

        // Apply point size
        symbolConfig = symbolConfig.applying(
            UIImage.SymbolConfiguration(pointSize: CGFloat(pointSize))
        )

        // Apply rendering mode configuration
        let renderingConfig = buildRenderingConfig(
            mode: modeString,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor
        )
        if let renderingConfig {
            symbolConfig = symbolConfig.applying(renderingConfig)
        }

        // Create the image
        var image = UIImage(systemName: parsed.name, withConfiguration: symbolConfig)

        // For monochrome mode, apply tint color via rendering mode
        if modeString == "monochrome", let color = primaryColor {
            image = image?.withTintColor(color, renderingMode: .alwaysOriginal)
        }

        imageView.image = image
    }

    private func buildRenderingConfig(
        mode: String,
        primaryColor: UIColor?,
        secondaryColor: UIColor?,
        tertiaryColor: UIColor?
    ) -> UIImage.SymbolConfiguration? {
        switch mode {
        case "hierarchical":
            if let color = primaryColor {
                return UIImage.SymbolConfiguration(hierarchicalColor: color)
            }
            return nil

        case "palette":
            var colors: [UIColor] = []
            if let c = primaryColor { colors.append(c) }
            if let c = secondaryColor { colors.append(c) }
            if let c = tertiaryColor { colors.append(c) }
            if !colors.isEmpty {
                return UIImage.SymbolConfiguration(paletteColors: colors)
            }
            return nil

        case "multicolor":
            return UIImage.SymbolConfiguration.preferringMulticolor()

        default:
            // monochrome — handled via tintColor separately
            return nil
        }
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
                return
            }
            applyParams(args)
            result(nil)

        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let isDark = args["isDark"] as? Bool {
                imageView.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Weight/Scale Mapping

    private func mapWeight(_ s: String) -> UIImage.SymbolWeight {
        switch s {
        case "ultraLight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }

    private func mapScale(_ s: String) -> UIImage.SymbolScale {
        switch s {
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        default: return .medium
        }
    }
}
