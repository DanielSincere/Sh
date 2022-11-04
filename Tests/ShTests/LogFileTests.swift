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

  func testUnwritableLogfile() throws {
    XCTAssertThrowsError(
      try sh(.file("/missing/path/sh-test.log"), #"echo "simple" > /unknown/path/name"#)
    ) { error in

      switch error {
      case Errors.openingLogError(let logError, underlyingError: let underlyingError):
        XCTAssertEqual(logError.localizedDescription, "The file “sh-test.log” couldn’t be opened because there is no such file.")

        XCTAssertTrue(underlyingError.localizedDescription.contains("CouldNotCreateFile error"))

      default:
        XCTFail("Expected an opening log error, but got \(error)")
      }
    }
  }
}
