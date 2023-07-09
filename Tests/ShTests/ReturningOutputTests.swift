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
