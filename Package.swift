// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NativeTabBar",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NativeTabBar",
            targets: ["NativeTabBar"]
        ),
    ],
    targets: [
        .target(
            name: "NativeTabBar",
            path: "Sources/NativeTabBar"
        ),
    ]
)
