// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "SwiftProjectWithFailingTests",
  platforms: [
    .macOS(.v12),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      from: "1.2.0"),

  ],
  targets: [
    .target(
      name: "SomeLibrary",
      dependencies: []),
    .testTarget(
      name: "SomeLibraryTests",
      dependencies: ["SomeLibrary"]),
  ])
