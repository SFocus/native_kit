import Flutter
import UIKit

/// Factory for creating NKToolbar (navigation bar) platform views (iOS 18.0+).
@available(iOS 18.0, *)
@objc public class NKToolbarViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKToolbarPlatformView(
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
final class NKToolbarPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let navBar: UINavigationBar
    private let navItem: UINavigationItem
    private var searchBar: UISearchBar?

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/toolbar_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        self.navBar = UINavigationBar(frame: frame)
        self.navItem = UINavigationItem()
        super.init()

        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.items = [navItem]
        container.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            navBar.topAnchor.constraint(equalTo: container.topAnchor),
            navBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
    }

    func view() -> UIView { container }

    // MARK: - Configuration

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        // Title
        navItem.title = params["title"] as? String

        // Large titles
        let prefersLargeTitles = params["prefersLargeTitles"] as? Bool ?? false
        navBar.prefersLargeTitles = prefersLargeTitles
        navItem.largeTitleDisplayMode = prefersLargeTitles ? .always : .never

        // Global tint
        if let tintColorValue = params["tintColor"] as? Int64 {
            navBar.tintColor = UIColor.fromARGB(tintColorValue)
        }

        // Appearance
        configureAppearance(params)

        // Leading: back button or custom item
        let showBackButton = params["showBackButton"] as? Bool ?? false
        if showBackButton {
            let backTitle = params["backButtonTitle"] as? String ?? "Back"
            let backItem = UIBarButtonItem(
                title: backTitle,
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )
            // Add chevron image alongside the title
            backItem.image = UIImage(systemName: "chevron.backward")
            navItem.leftBarButtonItem = backItem
        } else if let leadingData = params["leadingItem"] as? [String: Any] {
            navItem.leftBarButtonItem = makeBarButtonItem(
                from: leadingData,
                target: self,
                action: #selector(leadingItemTapped)
            )
        } else {
            navItem.leftBarButtonItem = nil
        }

        // Trailing items
        // Note: Items arrive already reversed from Dart so that Dart's
        // left-to-right order maps to UIKit's right-to-left rendering.
        let trailingData = params["trailingItems"] as? [[String: Any]] ?? []
        var trailingItems: [UIBarButtonItem] = []

        for (index, itemData) in trailingData.enumerated() {
            if let barItem = makeBarButtonItem(
                from: itemData,
                target: self,
                action: #selector(trailingItemTapped(_:))
            ) {
                // Tag maps to the reversed index; Dart handles un-reversing
                barItem.tag = trailingData.count - 1 - index
                trailingItems.append(barItem)
            }
        }

        navItem.rightBarButtonItems = trailingItems

        // Search bar
        configureSearchBar(params)
    }

    private func configureSearchBar(_ params: [String: Any]) {
        guard let searchConfig = params["searchBar"] as? [String: Any] else {
            // Remove search bar if config absent
            if searchBar != nil {
                navItem.titleView = nil
                searchBar = nil
            }
            return
        }

        let sb: UISearchBar
        if let existing = searchBar {
            sb = existing
        } else {
            sb = UISearchBar()
            sb.delegate = self
            sb.searchBarStyle = .minimal
            searchBar = sb
            navItem.titleView = sb
        }

        sb.placeholder = searchConfig["placeholder"] as? String ?? "Search"

        if let scopeTitles = searchConfig["scopeTitles"] as? [String], !scopeTitles.isEmpty {
            sb.showsScopeBar = true
            sb.scopeButtonTitles = scopeTitles
        } else {
            sb.showsScopeBar = false
            sb.scopeButtonTitles = nil
        }
    }

    private func configureAppearance(_ params: [String: Any]) {
        let appearanceName = params["appearance"] as? String ?? "defaultAppearance"
        let showSeparator = params["showSeparator"] as? Bool ?? true
        let bgColor: UIColor? = (params["backgroundColor"] as? Int64)
            .map { UIColor.fromARGB($0) }

        let appearance = UINavigationBarAppearance()

        switch appearanceName {
        case "transparent":
            appearance.configureWithTransparentBackground()
        case "opaque":
            appearance.configureWithOpaqueBackground()
            if let bg = bgColor {
                appearance.backgroundColor = bg
            }
        default:
            appearance.configureWithDefaultBackground()
            if let bg = bgColor {
                appearance.backgroundColor = bg
            }
        }

        if !showSeparator {
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
        }

        // Apply title text style
        if let textStyleDict = params["titleTextStyle"] as? [String: Any] {
            if let font = NKFontUtils.font(from: textStyleDict, defaultSize: 17.0) {
                appearance.titleTextAttributes[.font] = font
            }
            if let largeTitleFont = NKFontUtils.font(from: textStyleDict, defaultSize: 34.0) {
                appearance.largeTitleTextAttributes[.font] = largeTitleFont
            }
        }

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
    }

    private func makeBarButtonItem(
        from data: [String: Any],
        target: AnyObject,
        action: Selector
    ) -> UIBarButtonItem? {
        let enabled = data["enabled"] as? Bool ?? true
        let barItem: UIBarButtonItem

        if let iconDict = data["icon"] as? [String: Any],
           let image = NKSymbolUtils.createImageFromSource(iconDict) {
            barItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: target,
                action: action
            )
        } else if let label = data["label"] as? String {
            barItem = UIBarButtonItem(
                title: label,
                style: .plain,
                target: target,
                action: action
            )
        } else {
            return nil
        }

        barItem.isEnabled = enabled

        if let itemTint = data["tintColor"] as? Int64 {
            barItem.tintColor = UIColor.fromARGB(itemTint)
        }

        return barItem
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        channel.invokeMethod("onBackPressed", arguments: nil)
    }

    @objc private func leadingItemTapped() {
        channel.invokeMethod("onLeadingPressed", arguments: nil)
    }

    @objc private func trailingItemTapped(_ sender: UIBarButtonItem) {
        channel.invokeMethod("onTrailingPressed", arguments: sender.tag)
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - UISearchBarDelegate

@available(iOS 18.0, *)
extension NKToolbarPlatformView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        channel.invokeMethod("onSearchChanged", arguments: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        channel.invokeMethod("onSearchSubmitted", arguments: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        channel.invokeMethod("onSearchCancelled", arguments: nil)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        channel.invokeMethod("onScopeChanged", arguments: selectedScope)
    }
}
