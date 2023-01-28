import XCTest
import Sh

#if os(macOS)
final class MacTests: XCTestCase {

  struct Device: Codable {
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
  
  struct Devices: Codable {
    let devices: [String: [Device]]
  }
  
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
}
#endif
