// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "StandardInputFixture",
  platforms: [
    .macOS(.v13),
  ],
  dependencies: [
    .package(path: "../../"),
  ],
  targets: [
    .executableTarget(
      name: "StandardInputFixture",
      dependencies: ["Sh"]),
  ]
)
