// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ItchySDK",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "itchy", targets: ["itchy"]),
        .executable(name: "itchy-module-validator", targets: ["itchy-module-validator"])
    ],
    targets: [
        .target(
            name: "itchy",
            path: "Sources/itchy"
        ),
        .executableTarget(
            name: "itchy-module-validator",
            path: "Sources/itchy-module-validator"
        )
    ]
)
