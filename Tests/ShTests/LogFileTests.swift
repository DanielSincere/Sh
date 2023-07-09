import XCTest
import Foundation
@testable import Sh

final class LogFileTests: XCTestCase {

  func testSimple() throws {
    try sh(.file("/tmp/sh-test.log"), #"echo "simple""#)
    XCTAssertEqual(try String(contentsOfFile: "/tmp/sh-test.log"), "simple\n")
  }

  func testSimpleAsync() async throws {
    try await sh(.file("/tmp/sh-test.log"), #"echo "simple""#)
    XCTAssertEqual(try String(contentsOfFile: "/tmp/sh-test.log"), "simple\n")
  }

   func testPrintingErrorWhenFileOutputIsShort() throws {
     do {
       try sh(.file("/tmp/sh-test.log"), #"echo "simple" > /unknown/path/name"#)
       XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`")
     } catch Errors.errorWithLogInfo(let logInfo, underlyingError: let underlyingError) {

       XCTAssertTrue(logInfo.contains("/unknown/path/name"))

       let terminationError = try XCTUnwrap(underlyingError as? TerminationError)

       XCTAssertNotEqual(terminationError.status, 0)
       XCTAssertEqual(terminationError.reason, "`regular exit`")

       let error = Errors.errorWithLogInfo(logInfo, underlyingError: underlyingError)
       XCTAssertTrue(error.localizedDescription.contains("/unknown/path/name"))
     } catch {
       XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`, instead got an \(error)")
     }
   }

  func testPrintingErrorWhenFileOutputIsLong() throws {
    do {
      try sh(.file("/tmp/sh-test.log"), """
      swift test --package-path Fixtures/SwiftProjectWithFailingTests
      """)
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`")
    } catch Errors.errorWithLogInfo(let logInfo, underlyingError: let underlyingError) {

      XCTAssertTrue(logInfo.contains(#"XCTAssertEqual failed: ("Some name") is not equal to ("Wrong name")"#))

      let terminationError = try XCTUnwrap(underlyingError as? TerminationError)

      XCTAssertNotEqual(terminationError.status, 0)
      XCTAssertEqual(terminationError.reason, "`regular exit`")

      let error = Errors.errorWithLogInfo(logInfo, underlyingError: underlyingError)
      XCTAssertTrue(error.localizedDescription.contains(#"XCTAssertEqual failed: ("Some name") is not equal to ("Wrong name")"#))

//      print(error.localizedDescription)
    } catch {
      XCTFail("Expected the above to throw an `Errors.errorWithLogInfo`, instead got an \(error)")
    }
  }

  func testUnwritableLogfile() throws {
    do {
      try sh(.file("/missing/path/sh-test.log"), #"echo "simple" > /unknown/path/name"#)
    } catch Errors.openingLogError(let logError, underlyingError: let underlyingError) {

      #if os(Linux)
      XCTAssertEqual(logError.localizedDescription, "The operation could not be completed. No such file or directory")
      #else
      XCTAssertEqual(logError.localizedDescription, "The file “sh-test.log” couldn’t be opened because there is no such file.")
      #endif

      XCTAssertTrue(underlyingError.localizedDescription.contains("CouldNotCreateFile error"))

    } catch {
      XCTFail("Expected an opening log error, but got \(error)")
    }
  }
}
