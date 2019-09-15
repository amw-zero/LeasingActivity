// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "LeasingActivityServer",
    products: [
        .library(name: "LeasingActivityServer", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // LeasingActivity Behavior
        .package(url: "file:///Users/alexweisberger/code/LeasingActivityBehavior", .branch("filter-by-tenant-name"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "LeasingActivityBehavior"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

