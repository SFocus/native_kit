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
    private let container: UIView
    private var tabBar: UITabBar?
    private var selectedIndex: Int = 0
    private var items: [TabItemData] = []
    private var bgColor: UIColor?
    private var selectedItemColor: UIColor?
    private var unselectedItemColor: UIColor?

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
        self.container = UIView(frame: frame)
        super.init()

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
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        if let bgColor {
            appearance.backgroundColor = bgColor
        }

        if let selectedColor = selectedItemColor {
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: selectedColor
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            tabBar.tintColor = selectedColor
        }

        if let unselectedColor = unselectedItemColor {
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: unselectedColor
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            tabBar.unselectedItemTintColor = unselectedColor
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

        let image: UIImage? = data.iconName.flatMap { name in
            NKSymbolUtils.createImage(name: name, config: data.iconConfig)
        }

        let selectedImage: UIImage? = data.selectedIconName.flatMap { name in
            NKSymbolUtils.createImage(name: name, config: data.selectedIconConfig)
        }

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

// MARK: - Data Models

@available(iOS 18.0, *)
struct TabItemData {
    let title: String
    let iconName: String?
    let iconConfig: [String: Any]?
    let selectedIconName: String?
    let selectedIconConfig: [String: Any]?
    var badge: String?
    let isCustomButton: Bool

    init(from dict: [String: Any]) {
        self.title = dict["title"] as? String ?? ""
        self.badge = dict["badge"] as? String
        self.isCustomButton = dict["isCustomButton"] as? Bool ?? false

        if let parsed = NKSymbolUtils.parseIcon(from: dict["icon"] as? [String: Any]) {
            self.iconName = parsed.name
            self.iconConfig = parsed.config
        } else {
            self.iconName = nil
            self.iconConfig = nil
        }

        if let parsed = NKSymbolUtils.parseIcon(from: dict["selectedIcon"] as? [String: Any]) {
            self.selectedIconName = parsed.name
            self.selectedIconConfig = parsed.config
        } else {
            self.selectedIconName = nil
            self.selectedIconConfig = nil
        }
    }
}
