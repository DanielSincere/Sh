import Foundation
import XCTest
@testable import Sh

final class ReturningAllOutputTests: XCTestCase {
  
  func testSimple() throws {
    let process = Process(cmd: #"echo "simple""#)
    let allOutput = try process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut, "simple\n".data(using: .utf8)!)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
  
  func testSimpleAsync() async throws {
    let process = Process(cmd: #"echo "simple""#)
    let allOutput = try await process.runReturningAllOutput()
    
    XCTAssertEqual(allOutput.stdOut, "simple\n".data(using: .utf8)!)
    XCTAssertEqual(allOutput.stdErr, Data())
    XCTAssertNil(allOutput.terminationError)
  }
}
