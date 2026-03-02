import Flutter
import UIKit

/// Factory for creating NKPopupMenu platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKPopupMenuViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKPopupMenuPlatformView(
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
final class NKPopupMenuPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var button: UIButton!
    private var menuItems: [[String: Any]] = []

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/popup_menu_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        setupButton()
        configure(with: args)
    }

    func view() -> UIView { container }

    private func setupButton() {
        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true

        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        // Configure button appearance
        configureButtonAppearance(params)

        // Build and assign menu
        self.menuItems = params["items"] as? [[String: Any]] ?? []
        button.menu = buildMenu(from: menuItems)
    }

    private func configureButtonAppearance(_ params: [String: Any]) {
        // Apply tint color
        if let tintColorValue = params["tintColor"] as? Int64 {
            button.tintColor = UIColor.fromARGB(tintColorValue)
        }

        var config = UIButton.Configuration.plain()

        // Set button label
        if let label = params["buttonLabel"] as? String {
            config.title = label
        }

        // Set button icon
        if let iconDict = params["buttonIcon"] as? [String: Any],
           let image = NKSymbolUtils.createImageFromSource(iconDict) {
            config.image = image
            config.imagePadding = 4
        }

        button.configuration = config
    }

    private func buildMenu(from items: [[String: Any]]) -> UIMenu {
        // Group items by dividers to create inline sub-menus for visual separators
        var groups: [[(index: Int, data: [String: Any])]] = [[]]
        var actionIndex = 0

        for item in items {
            if item["isDivider"] as? Bool == true {
                // Start a new group
                groups.append([])
            } else {
                groups[groups.count - 1].append((index: actionIndex, data: item))
                actionIndex += 1
            }
        }

        // Remove empty groups
        groups = groups.filter { !$0.isEmpty }

        if groups.count <= 1 {
            // No dividers — flat menu
            let actions = groups.first?.map { createAction(from: $0.data, at: $0.index) } ?? []
            return UIMenu(title: "", children: actions)
        }

        // Multiple groups — use displayInline sub-menus for visual separators
        let subMenus: [UIMenu] = groups.map { group in
            let actions = group.map { createAction(from: $0.data, at: $0.index) }
            return UIMenu(title: "", options: .displayInline, children: actions)
        }

        return UIMenu(title: "", children: subMenus)
    }

    private func createAction(from data: [String: Any], at index: Int) -> UIAction {
        let title = data["label"] as? String ?? ""

        // Parse optional icon
        var image: UIImage? = nil
        if let iconDict = data["icon"] as? [String: Any] {
            image = NKSymbolUtils.createImageFromSource(iconDict)
        }

        // Determine attributes
        var attributes: UIMenuElement.Attributes = []
        if data["isDestructive"] as? Bool == true {
            attributes.insert(.destructive)
        }

        // Determine state
        let state: UIMenuElement.State = (data["isChecked"] as? Bool == true) ? .on : .off

        let action = UIAction(
            title: title,
            image: image,
            attributes: attributes,
            state: state
        ) { [weak self] _ in
            self?.channel.invokeMethod("onSelected", arguments: index)
        }

        return action
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
                return
            }
            applyParams(args)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
