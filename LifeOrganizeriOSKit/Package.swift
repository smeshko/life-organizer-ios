// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

// MARK: - Version Management
enum PackageVersion {
    static let tca = Version("1.21.0")
    static let dependencies = Version("1.9.0")
    static let grdb = Version("6.0.0")
    static let sharing = Version("1.0.5")
}

// MARK: - Package URLs
enum PackageURL {
    static let tca = "https://github.com/pointfreeco/swift-composable-architecture"
    static let dependencies = "https://github.com/pointfreeco/swift-dependencies"
    static let grdb = "https://github.com/groue/GRDB.swift"
    static let sharing = "https://github.com/pointfreeco/swift-sharing"
    static let transformers = "https://github.com/huggingface/swift-transformers"
}

// MARK: - Dependency References
enum Dependencies {
    static let tca = Target.Dependency.product(
        name: "ComposableArchitecture",
        package: "swift-composable-architecture"
    )
    static let dependencies = Target.Dependency.product(
        name: "Dependencies",
        package: "swift-dependencies"
    )
    static let grdb = Target.Dependency.product(
        name: "GRDB",
        package: "GRDB.swift"
    )
    static let sharing = Target.Dependency.product(
        name: "Sharing",
        package: "swift-sharing"
    )
}

// MARK: - Platform Configuration
enum PlatformConfiguration {
    static let standard: [SupportedPlatform] = [
        .iOS(.v18),
        .macOS(.v15)
    ]
}

// MARK: - Build Settings
enum BuildSettings {
    /// Swift 6 language mode settings with progressive concurrency adoption
    static let production: [SwiftSetting] = [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableUpcomingFeature("ExistentialAny")
    ]

    /// Debug-specific settings
    static let debug: [SwiftSetting] = [
        .define("DEBUG", .when(configuration: .debug)),
        .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=200"], .when(configuration: .debug))
    ]

    /// Testing-specific settings
    static let testing: [SwiftSetting] = production + [
        .define("TESTING")
    ]

    /// Standard settings for most targets
    static let standard: [SwiftSetting] = production + debug
}

// MARK: - Target Builders
extension Target {
    /// Creates a core module target with standard configuration
    static func core(
        _ name: String,
        dependencies: [Target.Dependency] = [],
        path: String? = nil,
        swiftSettings: [SwiftSetting]? = nil
    ) -> Target {
        return .target(
            name: name,
            dependencies: dependencies,
            path: path ?? "Sources/\(name)",
            swiftSettings: swiftSettings ?? BuildSettings.standard
        )
    }

    /// Creates a feature target with standard dependencies and configuration
    static func feature(
        _ name: String,
        path: String? = nil,
        dependencies: [Target.Dependency] = [],
        swiftSettings: [SwiftSetting]? = nil
    ) -> Target {
        let baseDependencies: [Target.Dependency] = [
            "Framework",
            Dependencies.tca,
            "CoreUI"
        ]

        return .target(
            name: name,
            dependencies: baseDependencies + dependencies,
            path: path ?? "Sources/Features/\(name)",
            swiftSettings: swiftSettings ?? BuildSettings.standard
        )
    }

    /// Creates a service target with standard configuration
    /// Automatically includes Framework and Dependencies as base dependencies
    static func service(
        _ name: String,
        dependencies: [Target.Dependency] = [],
        swiftSettings: [SwiftSetting]? = nil
    ) -> Target {
        let baseDependencies: [Target.Dependency] = [
            "Framework",
            Dependencies.dependencies
        ]

        return .target(
            name: name,
            dependencies: baseDependencies + dependencies,
            path: "Sources/Services/\(name)",
            swiftSettings: swiftSettings ?? BuildSettings.standard
        )
    }

    /// Creates a test target with standard testing configuration
    static func test(
        _ targetName: String,
        additionalDependencies: [Target.Dependency] = [],
        resources: [Resource]? = nil
    ) -> Target {
        return .testTarget(
            name: "\(targetName)Tests",
            dependencies: [.target(name: targetName)] + additionalDependencies,
            path: "Tests/\(targetName)Tests",
            resources: resources,
            swiftSettings: BuildSettings.testing
        )
    }
}

let package = Package(
    name: "LifeOrganizeriOSKit",
    platforms: PlatformConfiguration.standard,
    products: [
        // Core Modules
        .library(name: "Entities", targets: ["Entities"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "Framework", targets: ["Framework"]),
        .library(name: "CoreUI", targets: ["CoreUI"]),

        // Initial app feature
        .library(name: "AppFeature", targets: ["AppFeature"]),

        // Services
        .library(name: "NetworkService", targets: ["NetworkService"]),
        .library(name: "SpeechToTextService", targets: ["SpeechToTextService"]),
        .library(name: "ClassifierService", targets: ["ClassifierService"]),

        // Features
        .library(name: "ActionHandlerFeature", targets: ["ActionHandlerFeature"]),

        // Add your features and services here as you create them
        // Example:
        // .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    ],
    dependencies: [
        .package(url: PackageURL.tca, from: PackageVersion.tca),
        .package(url: PackageURL.dependencies, from: PackageVersion.dependencies),
        .package(url: PackageURL.sharing, from: PackageVersion.sharing),
        .package(url: PackageURL.transformers, from: "0.1.17")
        // Add GRDB when you need local persistence:
        // .package(url: PackageURL.grdb, from: PackageVersion.grdb),
    ],
    targets: [
        // MARK: - Core Modules
        .core("Entities"),
        .core("Shared", dependencies: [Dependencies.dependencies]),
        .core("Framework", dependencies: [Dependencies.tca, "Shared", Dependencies.sharing]),
        .target(
            name: "CoreUI",
            dependencies: ["Framework"],
            path: "Sources/CoreUI",
            resources: [
                .process("Resources")
            ],
            swiftSettings: BuildSettings.standard
        ),

        // MARK: - Features
        .feature("AppFeature", dependencies: ["ActionHandlerFeature"]),
        .feature("ActionHandlerFeature", dependencies: ["NetworkService", "Entities", "SpeechToTextService"]),

        // MARK: - Services
        .service("NetworkService"),
        .service("SpeechToTextService"),
        .service(
            "ClassifierService",
            dependencies: [
                .product(name: "Transformers", package: "swift-transformers"),
            ]
        ),

        // MARK: - Add Your Services Here
        // Example:
        // .service("MyService"),

        // MARK: - Add Your Features Here
        // Example:
        // .feature("SettingsFeature"),

        // MARK: - Test Targets
        .test("Framework"),
        .test("SpeechToTextService"),
        .test("CoreUI"),
        .test("ActionHandlerFeature", additionalDependencies: ["Entities", "NetworkService", "Framework"], resources: [.process("Resources")]),
    ]
)
