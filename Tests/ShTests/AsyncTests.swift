import Foundation
import XCTest
@testable import Sh

final class AsyncTests: XCTestCase {

  func testSimpleAsync() async throws {
    let process = Process(cmd: #"echo simple"#)
    let allOutput = try await process.runReturningAllOutput()

    XCTAssertEqual(allOutput.stdOut.asTrimmedString(), "simple")
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }

  func testCustomDecodeJsonOutputAsync() async throws {
    let json = #"'[{"type":"start","date":"2022-10-29T19:22:22Z"},{"type":"stop","date":"2023-10-29T19:22:22Z"}]'"#

    struct Event: Decodable {
      let type: String
      let date: Date
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let events = try await sh([Event].self, decodedBy: decoder, "echo \(json)")
    XCTAssertEqual(events.count, 2)
    XCTAssertEqual(events.first?.type, "start")
    XCTAssertEqual(events.first?.date.timeIntervalSince1970, 1667071342)
    XCTAssertEqual(events.last?.type, "stop")
    XCTAssertEqual(events.last?.date.timeIntervalSince1970, 1698607342)
  }

  func testPrintingErrorWhenFileOutputIsLong() throws {
    do {
      try sh(.file("/tmp/sh-AsyncTests.testPrintingErrorWhenFileOutputIsLong.log"), """
      swift test --package-path Fixtures/SwiftProjectWithFailingTests
      """)
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`")
    } catch Errors.errorWithLogInfo(let logInfo, underlyingError: let underlyingError) {

      XCTAssertTrue(logInfo.contains(#"XCTAssertEqual failed: ("Some name") is not equal to ("Wrong name")"#))

      let terminationError = try XCTUnwrap(underlyingError as? TerminationError)

      XCTAssertNotEqual(terminationError.status, 0)
      XCTAssertEqual(terminationError.reason, .exit)

      let error = Errors.errorWithLogInfo(logInfo, underlyingError: underlyingError)
      XCTAssertTrue(error.localizedDescription.contains(#"XCTAssertEqual failed: ("Some name") is not equal to ("Wrong name")"#))
    } catch {
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`, instead got an \(error)")
    }
  }
}
