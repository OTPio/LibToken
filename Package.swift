// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LibToken",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "LibToken", targets: ["LibToken"]),
    ],
    dependencies: [
        .package(url: "https://github.com/norio-nomura/Base32", from: "0.7.0")
    ],
    targets: [
        .target(name: "LibToken", dependencies: ["Base32"]),
//        .target(name: "RxLibToken", dependencies: ["LibToken"]),
        .testTarget(name: "LibTokenTests", dependencies: ["LibToken", "Base32"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
