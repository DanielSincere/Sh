import XCTest
import Sh

#if os(macOS)
final class MacTests: XCTestCase {
 
  func testSimctlListDevices() throws {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let wrapper = try sh(Devices.self,
                           decodedBy: decoder,
                           "xcrun simctl list -j devices")
    XCTAssertGreaterThanOrEqual(wrapper.devices.count, 0)
  }
  
  func testSimctlListDevicesAsync() async throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let wrapper = try await sh(Devices.self,
                               decodedBy: decoder,
                               "xcrun simctl list -j devices")
    XCTAssertGreaterThanOrEqual(wrapper.devices.count, 0)
  }
  
  func testSimctlListDevicesAllOutput() throws {
    let process = Process(cmd: "xcrun simctl list -j devices")
    let allOutput = try process.runReturningAllOutput()
    XCTAssertNil(allOutput.terminationError)
    XCTAssertGreaterThan(allOutput.stdOut.count, 0)
    XCTAssertTrue(allOutput.stdOut.asTrimmedString()?.localizedCaseInsensitiveContains("com.apple.CoreSimulator") ?? false)
    XCTAssertGreaterThan(allOutput.stdErr.count, 0)
    XCTAssertTrue(allOutput.stdErr.asTrimmedString()?.localizedCaseInsensitiveContains("Unknown binary with magic") ?? false)
  }
  
  func testSimctlListDevicesAllOutputAsync() async throws {
    let process = Process(cmd: "xcrun simctl list -j devices")
    let allOutput = try await process.runReturningAllOutput()
    XCTAssertNil(allOutput.terminationError)
    XCTAssertGreaterThan(allOutput.stdOut.count, 0)
    XCTAssertTrue(allOutput.stdOut.asTrimmedString()?.localizedCaseInsensitiveContains("com.apple.CoreSimulator") ?? false)
    XCTAssertGreaterThan(allOutput.stdErr.count, 0)
    XCTAssertTrue(allOutput.stdErr.asTrimmedString()?.localizedCaseInsensitiveContains("Unknown binary with magic") ?? false)
  }
  
  private struct Device: Codable {
    let availabilityError: String?
    let dataPath: String
    let dataPathSize: Int
    let deviceTypeIdentifier: String
    let isAvailable: Bool
    let lastBootedAt: Date?
    let logPath: String
    let logPathSize: Int?
    let name: String
    let state: String
    let udid: UUID
  }
  
  private struct Devices: Codable {
    let devices: [String: [Device]]
  }
}
#endif
