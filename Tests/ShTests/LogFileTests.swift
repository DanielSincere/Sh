import XCTest
@testable import Sh

final class LogFileTests: XCTestCase {

  func testSimple() throws {

    do {
      try sh(.file("/tmp/sh-test.log"), #"echo "simple" > /unknown/path/name"#)
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`")
    } catch Errors.errorWithLogInfo(let logInfo, underlyingError: let underlyingError) {
      XCTAssertEqual(logInfo, "/bin/sh: /unknown/path/name: No such file or directory")

      let terminationError = try XCTUnwrap(underlyingError as? TerminationError)

      XCTAssertEqual(terminationError.status, 1)
      XCTAssertEqual(terminationError.reason, "`regular exit`")
    } catch {
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`, instead got an \(error)")
    }
  }
}
