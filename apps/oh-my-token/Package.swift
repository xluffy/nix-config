// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "oh-my-token",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "oh-my-token", targets: ["OhMyToken"])],
    targets: [.executableTarget(name: "OhMyToken")]
)
