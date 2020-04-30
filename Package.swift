// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "rd-connect-adaptor",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.3"),
        .package(url: "https://github.com/ejp-rd-vp/ejp-rd-metadata-swift.git", from: "0.1.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "EJPRDMetadata"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

