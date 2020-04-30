// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ejp-rd-hackathon",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/ejp-rd-vp/ejp-rd-metadata-swift.git", from: "0.1.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "EJPRDMetadata"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

