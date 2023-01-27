// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "Sh",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .library(name: "Sh", targets: ["Sh"]),
  ],
  dependencies: [
    .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
  ],
  targets: [
    .target(name: "Sh", dependencies: ["Rainbow"]),
    .testTarget(name: "ShTests", dependencies: ["Sh"]),
  ])
