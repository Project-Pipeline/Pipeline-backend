// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PipelineBackend",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.3.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        
        // oauth
        .package(url: "https://github.com/vapor-community/Imperial.git", from: "1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Imperial", package: "Imperial"),
            .product(name: "JWT", package: "jwt"),
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App")
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App")
        ])
    ]
)

