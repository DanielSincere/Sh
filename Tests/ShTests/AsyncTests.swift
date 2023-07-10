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
