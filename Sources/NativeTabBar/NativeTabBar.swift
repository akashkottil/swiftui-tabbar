import SwiftUI
import UIKit

// MARK: - Tab Item Protocol

/// Define your tabs by conforming to this protocol.
/// Each tab provides a title, active icon, inactive icon, and an integer tag.
public protocol NativeTabItem: Hashable, CaseIterable {
    var title: String { get }
    var activeIcon: String { get }
    var inactiveIcon: String { get }
    var tag: Int { get }
}

// MARK: - Tab Bar Configuration

/// Appearance configuration for the native tab bar.
public struct NativeTabBarAppearance {
    public var activeColor: UIColor
    public var inactiveColor: UIColor
    public var activeFontSize: CGFloat
    public var activeFontWeight: UIFont.Weight
    public var inactiveFontSize: CGFloat
    public var inactiveFontWeight: UIFont.Weight
    public var backgroundColor: UIColor
    public var shadowColor: UIColor
    public var iconSize: CGSize

    public init(
        activeColor: UIColor = UIColor(red: 0.255, green: 0.004, blue: 0.58, alpha: 1),
        inactiveColor: UIColor = UIColor(red: 0.498, green: 0.533, blue: 0.667, alpha: 1),
        activeFontSize: CGFloat = 10,
        activeFontWeight: UIFont.Weight = .semibold,
        inactiveFontSize: CGFloat = 10,
        inactiveFontWeight: UIFont.Weight = .medium,
        backgroundColor: UIColor = .white,
        shadowColor: UIColor = UIColor.black.withAlphaComponent(0.06),
        iconSize: CGSize = CGSize(width: 24, height: 24)
    ) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.activeFontSize = activeFontSize
        self.activeFontWeight = activeFontWeight
        self.inactiveFontSize = inactiveFontSize
        self.inactiveFontWeight = inactiveFontWeight
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.iconSize = iconSize
    }
}

// MARK: - Native Tab Bar View

/// A SwiftUI TabView that uses UIKit's `UITabBarItem.image` and `UITabBarItem.selectedImage`
/// to display separate active/inactive icon images with `.alwaysOriginal` rendering.
///
/// Usage:
/// ```swift
/// NativeTabBarView(selection: $selectedTab, appearance: .init()) { tab in
///     switch tab {
///     case .home: HomeView()
///     case .profile: ProfileView()
///     }
/// }
/// ```
public struct NativeTabBarView<Tab: NativeTabItem, Content: View>: View {

    @Binding private var selection: Tab
    private let appearance: NativeTabBarAppearance
    private let content: (Tab) -> Content

    public init(
        selection: Binding<Tab>,
        appearance: NativeTabBarAppearance = .init(),
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self._selection = selection
        self.appearance = appearance
        self.content = content
        Self.configureGlobalAppearance(appearance)
    }

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(Tab.allCases), id: \.self) { tab in
                content(tab)
                    .tabItem {
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
        .onAppear {
            applyNativeTabBarItems()
        }
        .onChange(of: selection) {
            applyNativeTabBarItems()
        }
    }

    // MARK: - Apply Native Icons

    private func applyNativeTabBarItems() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let tabBarController = Self.findTabBarController() else { return }
            guard let items = tabBarController.tabBar.items else { return }

            for tab in Tab.allCases {
                guard tab.tag < items.count else { continue }
                let item = items[tab.tag]

                if let inactiveImage = Self.resizedImage(named: tab.inactiveIcon, to: appearance.iconSize) {
                    item.image = inactiveImage.withRenderingMode(.alwaysOriginal)
                }
                if let activeImage = Self.resizedImage(named: tab.activeIcon, to: appearance.iconSize) {
                    item.selectedImage = activeImage.withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }

    // MARK: - UIKit Helpers

    private static func resizedImage(named name: String, to size: CGSize) -> UIImage? {
        guard let original = UIImage(named: name) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private static func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return nil }
        return findTabBarController(in: window.rootViewController)
    }

    private static func findTabBarController(in controller: UIViewController?) -> UITabBarController? {
        if let tabBar = controller as? UITabBarController {
            return tabBar
        }
        for child in controller?.children ?? [] {
            if let found = findTabBarController(in: child) {
                return found
            }
        }
        if let presented = controller?.presentedViewController {
            return findTabBarController(in: presented)
        }
        return nil
    }

    // MARK: - Global Appearance

    private static func configureGlobalAppearance(_ config: NativeTabBarAppearance) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = config.backgroundColor
        appearance.shadowColor = config.shadowColor

        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: config.activeColor,
            .font: UIFont.systemFont(ofSize: config.activeFontSize, weight: config.activeFontWeight)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: config.inactiveColor,
            .font: UIFont.systemFont(ofSize: config.inactiveFontSize, weight: config.inactiveFontWeight)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
