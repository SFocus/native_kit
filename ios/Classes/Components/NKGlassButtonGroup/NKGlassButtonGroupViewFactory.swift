import Flutter
import UIKit

/// Factory for creating NKGlassButtonGroup platform views (iOS 26.0+)
@available(iOS 26.0, *)
@objc public class NKGlassButtonGroupViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKGlassButtonGroupPlatformView(
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
final class NKGlassButtonGroupPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var containerView: UIVisualEffectView!
    private var stackView: UIStackView!

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/glass_button_group_\(viewId)",
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

        let spacing = arguments["spacing"] as? CGFloat ?? 12.0
        let buttons = arguments["buttons"] as? [[String: Any]] ?? []

        // Create the glass container
        containerView = NKGlassUtils.makeGlassContainerView(spacing: spacing)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: container.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        // Create the stack view inside contentView
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.contentView.centerYAnchor),
        ])

        // Build buttons
        buildButtons(from: buttons)
    }

    // MARK: - Button Building

    private func buildButtons(from buttonDataList: [[String: Any]]) {
        // Remove existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, buttonData) in buttonDataList.enumerated() {
            let button = UIButton(configuration: .glass())

            if let label = buttonData["label"] as? String {
                button.configuration?.title = label
            }

            if let iconData = buttonData["icon"] as? [String: Any],
               let image = NKSymbolUtils.createImageFromSource(iconData) {
                button.configuration?.image = image
                let hasLabel = buttonData["label"] as? String != nil
                button.configuration?.imagePadding = hasLabel ? 6 : 0
            }

            if let colorValue = buttonData["tintColor"] as? Int64 {
                let tintColor = UIColor.fromARGB(colorValue)
                button.configuration?.baseForegroundColor = tintColor
                button.tintColor = tintColor
            }

            button.tag = index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)

            stackView.addArrangedSubview(button)
        }
    }

    // MARK: - Button Action

    @objc private func buttonPressed(_ sender: UIButton) {
        channel.invokeMethod("onButtonPressed", arguments: sender.tag)
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
                return
            }

            let buttons = args["buttons"] as? [[String: Any]] ?? []
            buildButtons(from: buttons)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
