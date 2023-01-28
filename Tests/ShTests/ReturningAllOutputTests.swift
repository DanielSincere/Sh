import Foundation
import XCTest
@testable import Sh

final class ReturningAllOutputTests: XCTestCase {
  
  func testSimple() throws {
    let allOutput = try Process(cmd: #"echo "simple""#).runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut, "simple\n".data(using: .utf8)!)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  func testSimpleAsync() async throws {
    let allOutput = try await Process(cmd: #"echo "simple""#).runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut, "simple\n".data(using: .utf8)!)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
}
