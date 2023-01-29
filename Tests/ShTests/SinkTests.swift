import XCTest
import Sh

final class SinkTests: XCTestCase {
  
  func testTerminal() throws {
    try sh(.terminal, "echo 'hello'")
  }
  
  func testTerminalAsync() async throws {
    try await sh(.terminal, "echo 'hello'")
  }
}
