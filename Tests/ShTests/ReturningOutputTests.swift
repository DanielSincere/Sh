import XCTest
@testable import Sh

final class ReturningOutputTests: XCTestCase {

  func testSimple() throws {
    XCTAssertEqual("simple", try sh(#"echo "simple""#))
  }

  func testEmptyStringOutput() throws {
    let output: String? = try sh("mkdir -p /tmp")
    XCTAssertEqual(output?.count, 0)
  }

  func testEmptyDataOutput() throws {
    let output: Data = try Process(cmd: "mkdir -p /tmp").runReturningData()
    XCTAssertEqual(output.count, 0)
  }

  func testJsonOutput() throws {
    let json = #"[{"name":"Iodine","color":"purple"}, {"name":"Oxygen","color":"clear"}]"#

    struct Gas: Codable {
      let name: String
      let color: Color
      enum Color: String, Codable {
        case clear, purple
      }
    }

    let gasses = try sh([Gas].self, "echo '\(json)'")
    XCTAssertEqual(gasses.count, 2)
    XCTAssertEqual(gasses.first?.name, "Iodine")
    XCTAssertEqual(gasses.last?.color, .clear)
  }
  
  func testCustomDecodeJsonOutput() throws {
    let json = #"[{"type":"start","date":"2022-10-29T19:22:22Z"},{"type":"stop","date": "2023-10-29T19:22:22Z"}]"#
    
    struct Event: Codable {
      let type: String
      let date: Date
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let events = try sh([Event].self, decodedBy: decoder, "echo '\(json)'")
    XCTAssertEqual(events.count, 2)
    XCTAssertEqual(events.first?.type, "start")
    XCTAssertEqual(events.first?.date.timeIntervalSince1970, 1667071342)
    XCTAssertEqual(events.last?.type, "stop")
    XCTAssertEqual(events.last?.date.timeIntervalSince1970, 1698607342)
  }
  


  func testNilOrEmptyOutputThrowsErrorWhenDecoding() {
    do {
      let _ = try sh([Int].self, "echo")
    } catch Swift.DecodingError.dataCorrupted(_) {
      // success
    } catch {
      XCTFail("unexpected error: \(error)")
    }
  }

  func testDecodingStringOutput() throws {
    XCTAssertEqual(1, try sh(Int.self, "echo 1"))
    XCTAssertEqual(Date().timeIntervalSince1970, try sh(TimeInterval.self, "date +%s"), accuracy: 1)
  }
}
