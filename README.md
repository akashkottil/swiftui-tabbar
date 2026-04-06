# NativeTabBar for SwiftUI

A lightweight Swift package that lets you use **separate active and inactive icon images** in SwiftUI's native `TabView` — powered by UIKit's `UITabBarItem.image` and `UITabBarItem.selectedImage` under the hood.

## The Problem

SwiftUI's `.tabItem` doesn't natively support separate images for selected vs unselected states. You either get:
- Template-rendered icons (single color tint)
- Hacky workarounds with state-driven `Image` swaps that flicker

## The Solution

This package bridges SwiftUI and UIKit cleanly:

1. SwiftUI's `TabView` handles the view hierarchy and selection state
2. On every appearance and tab change, the package finds the underlying `UITabBarController`
3. Sets `item.image` (unselected) and `item.selectedImage` (selected) with `.alwaysOriginal`
4. UIKit's native tab bar automatically swaps between the two images on tap — zero SwiftUI state needed for icons

## Installation

### Swift Package Manager

Add this to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/akashkottil/swiftui-tabbar.git", from: "1.0.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and paste:

```
https://github.com/akashkottil/swiftui-tabbar.git
```

## Usage

### Step 1: Define Your Tabs

Create an enum conforming to `NativeTabItem`:

```swift
import NativeTabBar

enum AppTab: Int, NativeTabItem, CaseIterable {
    case home = 0
    case search = 1
    case profile = 2

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .profile: return "Profile"
        }
    }

    // Icon shown when tab is SELECTED
    var activeIcon: String {
        switch self {
        case .home: return "home_active"       // Asset catalog name
        case .search: return "search_active"
        case .profile: return "profile_active"
        }
    }

    // Icon shown when tab is NOT selected
    var inactiveIcon: String {
        switch self {
        case .home: return "home_inactive"
        case .search: return "search_inactive"
        case .profile: return "profile_inactive"
        }
    }

    var tag: Int { rawValue }
}
```

### Step 2: Add Icon Assets

Add your active and inactive icon images to your Xcode **Asset Catalog**. Supported formats:
- **SVG** (recommended) — set `width` and `height` attributes, remove `preserveAspectRatio="none"`
- **PDF** vector assets
- **PNG** at 1x/2x/3x

For SVG assets, use this `Contents.json`:

```json
{
  "images": [{ "filename": "icon_name.svg", "idiom": "universal" }],
  "info": { "author": "xcode", "version": 1 },
  "properties": {
    "preserves-vector-representation": true,
    "template-rendering-intent": "original"
  }
}
```

> **Important:** Set `template-rendering-intent` to `"original"` so iOS preserves your icon colors instead of applying a tint.

### Step 3: Use NativeTabBarView

```swift
import SwiftUI
import NativeTabBar

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        NativeTabBarView(selection: $selectedTab) { tab in
            switch tab {
            case .home:
                NavigationStack { HomeView() }
            case .search:
                NavigationStack { SearchView() }
            case .profile:
                NavigationStack { ProfileView() }
            }
        }
    }
}
```

### Customizing Appearance

Pass a `NativeTabBarAppearance` to customize colors, fonts, and icon size:

```swift
NativeTabBarView(
    selection: $selectedTab,
    appearance: NativeTabBarAppearance(
        activeColor: UIColor.systemBlue,
        inactiveColor: UIColor.systemGray,
        activeFontSize: 11,
        activeFontWeight: .bold,
        inactiveFontSize: 11,
        inactiveFontWeight: .regular,
        backgroundColor: .white,
        iconSize: CGSize(width: 28, height: 28)
    )
) { tab in
    // ...
}
```

#### NativeTabBarAppearance Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `activeColor` | `UIColor` | Purple | Selected tab text color |
| `inactiveColor` | `UIColor` | Gray | Unselected tab text color |
| `activeFontSize` | `CGFloat` | `10` | Selected tab label font size |
| `activeFontWeight` | `UIFont.Weight` | `.semibold` | Selected tab label font weight |
| `inactiveFontSize` | `CGFloat` | `10` | Unselected tab label font size |
| `inactiveFontWeight` | `UIFont.Weight` | `.medium` | Unselected tab label font weight |
| `backgroundColor` | `UIColor` | `.white` | Tab bar background color |
| `shadowColor` | `UIColor` | Black 6% | Tab bar shadow color |
| `iconSize` | `CGSize` | `24x24` | Icon rendering size |

## How It Works

```
SwiftUI TabView
    |
    |-- .tabItem { Text(title) }    <-- placeholder, just sets the label
    |-- .tag(tab)
    |
    |-- .onAppear / .onChange(of: selection)
            |
            v
    applyNativeTabBarItems()
            |
            |-- Finds UITabBarController in the view hierarchy
            |-- For each tab:
            |       item.image = UIImage(inactive).alwaysOriginal
            |       item.selectedImage = UIImage(active).alwaysOriginal
            |
            v
    UIKit handles the rest (automatic swap on tap)
```

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15+

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

**Akash Kottil** — [@akashkottil](https://github.com/akashkottil)
