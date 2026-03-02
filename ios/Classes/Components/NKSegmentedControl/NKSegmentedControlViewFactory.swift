import Flutter
import UIKit

/// Factory for creating NKSegmentedControl platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKSegmentedControlViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKSegmentedControlPlatformView(
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
final class NKSegmentedControlPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var segmentedControl: UISegmentedControl!

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/segmented_control_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
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

        let labels = arguments["labels"] as? [String] ?? []
        let iconsData = arguments["icons"] as? [Any?]
        let selectedIndex = arguments["selectedIndex"] as? Int ?? 0
        let enabled = arguments["enabled"] as? Bool ?? true

        // Create the segmented control
        segmentedControl = UISegmentedControl(items: [])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Add segments
        for (index, label) in labels.enumerated() {
            segmentedControl.insertSegment(withTitle: label, at: index, animated: false)

            // Add icon if provided
            if let iconsData = iconsData,
               index < iconsData.count,
               let iconDict = iconsData[index] as? [String: Any],
               let parsed = NKSymbolUtils.parseIcon(from: iconDict),
               let image = NKSymbolUtils.createImage(name: parsed.name, config: parsed.config) {
                segmentedControl.setImage(image.withRenderingMode(.alwaysTemplate), forSegmentAt: index)
            }
        }

        // Set selected index
        if labels.indices.contains(selectedIndex) {
            segmentedControl.selectedSegmentIndex = selectedIndex
        }

        // Set enabled state
        segmentedControl.isEnabled = enabled

        // Apply tint color
        if let colorValue = arguments["tintColor"] as? Int64 {
            segmentedControl.selectedSegmentTintColor = UIColor.fromARGB(colorValue)
        }

        // Apply text style
        applyStyling(arguments)

        // Add target for value changes
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        container.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: container.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }

    private func applyStyling(_ params: [String: Any]) {
        if let textStyleDict = params["textStyle"] as? [String: Any],
           let font = NKFontUtils.font(from: textStyleDict, defaultSize: 13.0) {
            let attrs: [NSAttributedString.Key: Any] = [.font: font]
            segmentedControl.setTitleTextAttributes(attrs, for: .normal)
            segmentedControl.setTitleTextAttributes(attrs, for: .selected)
        }

        if let cornerRadius = params["cornerRadius"] as? CGFloat {
            segmentedControl.layer.cornerRadius = cornerRadius
            segmentedControl.clipsToBounds = true
        }
    }

    // MARK: - Segment Action

    @objc private func valueChanged() {
        channel.invokeMethod("onValueChanged", arguments: segmentedControl.selectedSegmentIndex)
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
            return
        }

        switch call.method {
        case "setSelectedIndex":
            guard let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected 'index' int", details: nil))
                return
            }
            if (0..<segmentedControl.numberOfSegments).contains(index) {
                segmentedControl.selectedSegmentIndex = index
            }
            result(nil)

        case "setEnabled":
            guard let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected 'enabled' bool", details: nil))
                return
            }
            segmentedControl.isEnabled = enabled
            result(nil)

        case "updateStyling":
            applyStyling(args)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
