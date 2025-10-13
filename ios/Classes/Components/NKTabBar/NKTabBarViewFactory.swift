import Flutter
import UIKit

/// Factory for creating NKTabBar platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar
    private let channel: FlutterMethodChannel
    private var platformViews: [Int64: NKTabBarPlatformView] = [:]

    @objc public init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let platformView = platformViews.values.first else {
            result(FlutterError(code: "NO_VIEW", message: "No platform view found", details: nil))
            return
        }

        switch call.method {
        case "setSelectedIndex":
            guard let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_INDEX", message: "Invalid index", details: nil))
                return
            }
            platformView.setSelectedIndex(index)
            result(nil)

        case "setBadge":
            guard let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_INDEX", message: "Invalid index", details: nil))
                return
            }
            platformView.setBadge(index: index, badge: args["badge"] as? String)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let platformView = NKTabBarPlatformView(
            frame: frame,
            viewId: viewId,
            arguments: args,
            registrar: registrar,
            channel: channel
        )
        platformViews[viewId] = platformView
        return platformView
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

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar,
        channel: FlutterMethodChannel
    ) {
        self.channel = channel
        self.container = UIView(frame: frame)
        super.init()

        configure(with: args)
        setupTabBar()
    }

    func view() -> UIView { container }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }

        let itemsData = arguments["items"] as? [[String: Any]] ?? []
        self.items = itemsData.map { TabItemData(from: $0) }
        self.selectedIndex = arguments["currentIndex"] as? Int ?? 0
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

        if data.isCustomButton {
            item = UITabBarItem(tabBarSystemItem: .search, tag: index)
            if let iconName = data.iconName {
                item.image = UIImage(systemName: iconName)
            }
            if let selectedIconName = data.selectedIconName {
                item.selectedImage = UIImage(systemName: selectedIconName)
            }
            if !data.title.isEmpty && data.title != "Search" {
                item.title = data.title
            }
        } else {
            item = UITabBarItem(
                title: data.title,
                image: data.iconName.flatMap { UIImage(systemName: $0) },
                tag: index
            )
            if let selectedIconName = data.selectedIconName {
                item.selectedImage = UIImage(systemName: selectedIconName)
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
    let selectedIconName: String?
    var badge: String?
    let isCustomButton: Bool

    init(from dict: [String: Any]) {
        self.title = dict["title"] as? String ?? ""
        self.badge = dict["badge"] as? String
        self.isCustomButton = dict["isCustomButton"] as? Bool ?? false

        self.iconName = (dict["icon"] as? [String: Any])
            .flatMap { $0["type"] as? String == "sf_symbol" ? $0["name"] as? String : nil }

        self.selectedIconName = (dict["selectedIcon"] as? [String: Any])
            .flatMap { $0["type"] as? String == "sf_symbol" ? $0["name"] as? String : nil }
    }
}
