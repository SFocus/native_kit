import Flutter
import UIKit

/// Factory for creating NKTabBar platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKTabBarPlatformView(
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
final class NKTabBarPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: NKTabBarContainerView
    private var tabBar: UITabBar?
    private var selectedIndex: Int = 0
    private var items: [TabItemData] = []
    private var bgColor: UIColor?
    private var selectedItemColor: UIColor?
    private var unselectedItemColor: UIColor?
    private var textStyleDict: [String: Any]?

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/tab_bar_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = NKTabBarContainerView(frame: frame)
        self.container.backgroundColor = .clear
        super.init()
        self.container.platformView = self

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
        setupTabBar()
    }

    func view() -> UIView { container }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }

        let itemsData = arguments["items"] as? [[String: Any]] ?? []
        self.items = itemsData.map { TabItemData(from: $0) }
        self.selectedIndex = arguments["currentIndex"] as? Int ?? 0

        if let color = arguments["backgroundColor"] as? Int64 {
            self.bgColor = UIColor.fromARGB(color)
        }
        if let color = arguments["selectedItemColor"] as? Int64 {
            self.selectedItemColor = UIColor.fromARGB(color)
        }
        if let color = arguments["unselectedItemColor"] as? Int64 {
            self.unselectedItemColor = UIColor.fromARGB(color)
        }
        self.textStyleDict = arguments["textStyle"] as? [String: Any]
    }

    private func setupTabBar() {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self

        configureAppearance(tabBar)
        configureItems(tabBar)

        container.addSubview(tabBar)
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tabBar.topAnchor.constraint(equalTo: container.topAnchor),
            tabBar.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        self.tabBar = tabBar
    }

    private func configureAppearance(_ tabBar: UITabBar) {
        // Reset direct color properties so stale values don't persist
        // when colors are removed or when iOS alters them during transitions.
        tabBar.tintColor = nil
        tabBar.unselectedItemTintColor = nil

        // On iOS 26+, skip custom appearance to let Liquid Glass apply automatically.
        // Only set explicit colors if provided.
        if #available(iOS 26.0, *) {
            let appearance = UITabBarAppearance()
            if let bgColor {
                // Opaque background — no blur sampling, eliminates the navigation blink
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = bgColor
            } else {
                // Pure Liquid Glass when the caller doesn't request a specific background
                appearance.configureWithDefaultBackground()
            }

            if let selectedColor = selectedItemColor {
                tabBar.tintColor = selectedColor
            }
            if let unselectedColor = unselectedItemColor {
                tabBar.unselectedItemTintColor = unselectedColor
            }

            // Apply text style
            if let font = NKFontUtils.font(from: textStyleDict, defaultSize: 10.0) {
                appearance.stackedLayoutAppearance.normal.titleTextAttributes[.font] = font
                appearance.stackedLayoutAppearance.selected.titleTextAttributes[.font] = font
            }

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
            return
        }

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        if let bgColor {
            appearance.backgroundColor = bgColor
        }

        // Build font from text style
        let font = NKFontUtils.font(from: textStyleDict, defaultSize: 10.0)

        if let selectedColor = selectedItemColor {
            var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: selectedColor]
            if let font { attrs[.font] = font }
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = attrs
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            tabBar.tintColor = selectedColor
        } else if let font {
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.font: font]
        }

        if let unselectedColor = unselectedItemColor {
            var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: unselectedColor]
            if let font { attrs[.font] = font }
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = attrs
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            tabBar.unselectedItemTintColor = unselectedColor
        } else if let font {
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.font: font]
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func configureItems(_ tabBar: UITabBar) {
        let tabBarItems = items.enumerated().map { index, itemData in
            createTabBarItem(from: itemData, at: index)
        }

        tabBar.items = tabBarItems
        tabBar.selectedItem = tabBarItems.indices.contains(selectedIndex) ? tabBarItems[selectedIndex] : nil
    }

    private func createTabBarItem(from data: TabItemData, at index: Int) -> UITabBarItem {
        let item: UITabBarItem

        let image = NKSymbolUtils.createImageFromSource(data.iconDict)
        let selectedImage = NKSymbolUtils.createImageFromSource(data.selectedIconDict)

        if data.isCustomButton {
            item = UITabBarItem(tabBarSystemItem: .search, tag: index)
            if let img = image { item.image = img }
            if let selImg = selectedImage { item.selectedImage = selImg }
            if !data.title.isEmpty && data.title != "Search" {
                item.title = data.title
            }
        } else {
            item = UITabBarItem(
                title: data.title,
                image: image,
                tag: index
            )
            if let selImg = selectedImage {
                item.selectedImage = selImg
            }
        }

        item.badgeValue = data.badge
        return item
    }

    /// Re-applies the current appearance to the tab bar.
    /// Called by the container view when it returns to a window after navigation.
    func reapplyAppearance() {
        guard let tabBar = self.tabBar else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        configureAppearance(tabBar)
        CATransaction.commit()
    }

    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
        guard let items = tabBar?.items, items.indices.contains(index) else { return }
        tabBar?.selectedItem = items[index]
    }

    func setBadge(index: Int, badge: String?) {
        guard items.indices.contains(index) else { return }
        items[index].badge = badge
        tabBar?.items?[index].badgeValue = badge
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
            return
        }

        switch call.method {
        case "update":
            // Re-parse all params
            let itemsData = args["items"] as? [[String: Any]] ?? []
            self.items = itemsData.map { TabItemData(from: $0) }
            self.selectedIndex = args["currentIndex"] as? Int ?? 0

            // Reset colors before re-applying so removed colors clear properly
            self.bgColor = nil
            self.selectedItemColor = nil
            self.unselectedItemColor = nil

            if let color = args["backgroundColor"] as? Int64 {
                self.bgColor = UIColor.fromARGB(color)
            }
            if let color = args["selectedItemColor"] as? Int64 {
                self.selectedItemColor = UIColor.fromARGB(color)
            }
            if let color = args["unselectedItemColor"] as? Int64 {
                self.unselectedItemColor = UIColor.fromARGB(color)
            }
            self.textStyleDict = args["textStyle"] as? [String: Any]

            // Rebuild appearance and items on the existing tab bar
            if let tabBar = self.tabBar {
                configureAppearance(tabBar)
                configureItems(tabBar)
            }
            result(nil)

        case "setSelectedIndex":
            guard let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_INDEX", message: "Invalid index", details: nil))
                return
            }
            setSelectedIndex(index)
            result(nil)

        case "setBadge":
            guard let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_INDEX", message: "Invalid index", details: nil))
                return
            }
            setBadge(index: index, badge: args["badge"] as? String)
            result(nil)

        case "setVisible":
            guard let visible = args["visible"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected 'visible' bool", details: nil))
                return
            }
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.tabBar?.isHidden = !visible
                self?.container.isHidden = !visible
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - UITabBarDelegate

@available(iOS 18.0, *)
extension NKTabBarPlatformView: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = item.tag

        guard items.indices.contains(index) else { return }

        if items[index].isCustomButton {
            channel.invokeMethod("onCustomButtonTap", arguments: index)
            DispatchQueue.main.async { [weak self] in
                guard let self,
                      let items = tabBar.items,
                      items.indices.contains(self.selectedIndex) else { return }
                tabBar.selectedItem = items[self.selectedIndex]
            }
            return
        }

        selectedIndex = index
        channel.invokeMethod("onTabSelected", arguments: index)
    }
}

// MARK: - Container View

/// Custom container that re-applies tab bar appearance when the view
/// comes back into view (e.g., after a pushed route is popped).
/// iOS may alter tintColor/appearance during navigation transitions.
@available(iOS 18.0, *)
private class NKTabBarContainerView: UIView {
    weak var platformView: NKTabBarPlatformView?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            platformView?.reapplyAppearance()
        }
    }
}

// MARK: - Data Models

@available(iOS 18.0, *)
struct TabItemData {
    let title: String
    let iconDict: [String: Any]?
    let selectedIconDict: [String: Any]?
    var badge: String?
    let isCustomButton: Bool

    init(from dict: [String: Any]) {
        self.title = dict["title"] as? String ?? ""
        self.badge = dict["badge"] as? String
        self.isCustomButton = dict["isCustomButton"] as? Bool ?? false
        self.iconDict = dict["icon"] as? [String: Any]
        self.selectedIconDict = dict["selectedIcon"] as? [String: Any]
    }
}
