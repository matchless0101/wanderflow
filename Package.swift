// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WanderFlow",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .library(name: "WanderFlowLib", targets: ["WanderFlowLib"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "WanderFlowLib",
            dependencies: [
            ],
            path: "WanderFlow",
            exclude: [
                "WanderFlowApp.swift", // Exclude App entry point to avoid main conflicts if any
                "Assets.xcassets",
                "Preview Content"
            ],
            sources: [
                "Core",
                "Features",
                "Models",
                "Services",
                "ViewModels",
                "ContentView.swift" // Include UI if needed, but might be tricky
            ]
        ),
        .testTarget(
            name: "WanderFlowTests",
            dependencies: ["WanderFlowLib"],
            path: "Tests"
        )
    ]
)
