// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HostSwiftUIApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "HostSwiftUIApp", targets: ["HostSwiftUIApp"])
    ],
    targets: [
        .executableTarget(name: "HostSwiftUIApp")
    ]
)
