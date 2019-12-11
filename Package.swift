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
        .package(url: "https://github.com/mattrubin/Bases.git", Package.Dependency.Requirement.branch("develop"))
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
