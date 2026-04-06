import SwiftUI
import NativeTabBar

// MARK: - 1. Define Your Tabs

enum AppTab: Int, NativeTabItem, CaseIterable {
    case search = 0
    case hotels = 1
    case carRental = 2
    case settings = 3

    var title: String {
        switch self {
        case .search: return "Search"
        case .hotels: return "Hotels"
        case .carRental: return "Car Rental"
        case .settings: return "Settings"
        }
    }

    var activeIcon: String {
        switch self {
        case .search: return "tab_flight_active"
        case .hotels: return "tab_hotel_active"
        case .carRental: return "tab_car_active"
        case .settings: return "tab_settings_active"
        }
    }

    var inactiveIcon: String {
        switch self {
        case .search: return "tab_flight_inactive"
        case .hotels: return "tab_hotel_inactive"
        case .carRental: return "tab_car_inactive"
        case .settings: return "tab_settings_inactive"
        }
    }

    var tag: Int { rawValue }
}

// MARK: - 2. Use NativeTabBarView

struct ContentView: View {

    @State private var selectedTab: AppTab = .search

    var body: some View {
        NativeTabBarView(
            selection: $selectedTab,
            appearance: NativeTabBarAppearance(
                activeColor: UIColor(red: 0.255, green: 0.004, blue: 0.58, alpha: 1),
                inactiveColor: UIColor(red: 0.498, green: 0.533, blue: 0.667, alpha: 1),
                iconSize: CGSize(width: 24, height: 24)
            )
        ) { tab in
            switch tab {
            case .search:
                NavigationStack {
                    Text("Search View")
                        .navigationTitle("Search")
                }
            case .hotels:
                NavigationStack {
                    Text("Hotels View")
                        .navigationTitle("Hotels")
                }
            case .carRental:
                NavigationStack {
                    Text("Car Rental View")
                        .navigationTitle("Car Rental")
                }
            case .settings:
                NavigationStack {
                    Text("Settings View")
                        .navigationTitle("Settings")
                }
            }
        }
    }
}
