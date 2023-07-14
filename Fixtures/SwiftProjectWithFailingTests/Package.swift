// swift-tools-version:5.8

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
    .package(
      url: "https://github.com/apple/swift-markdown",
      from: "0.2.0"),
    .package(
      url: "https://github.com/apple/swift-http-types",
      from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "SomeLibrary",
      dependencies: []),
    .testTarget(
      name: "SomeLibraryTests",
      dependencies: ["SomeLibrary"]),
  ])
