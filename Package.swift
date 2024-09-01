// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ParentReducer",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "ParentReducer",
            targets: ["ParentReducer"]
        ),
        .executable(
            name: "ParentReducerClient",
            targets: ["ParentReducerClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.10.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.4.0")
    ],
    targets: [
        .macro(
            name: "ParentReducerImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/Implementation"
        ),
        .target(
            name: "ParentReducer",
            dependencies: [
                "ParentReducerImplementation",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .executableTarget(
            name: "ParentReducerClient",
            dependencies: [
                "ParentReducer"
            ],
            path: "Sources/Client"
        ),
        .testTarget(
            name: "ParentReducerTests",
            dependencies: [
                "ParentReducerImplementation",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing")
            ]
        ),
    ]
)
