// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "vero-test-fixtures-swift",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio-http2.git", exact: "1.28.0"),
    ],
    targets: [
        .executableTarget(name: "Fixture", dependencies: [
            .product(name: "NIOHTTP2", package: "swift-nio-http2"),
        ]),
    ]
)
