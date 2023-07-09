@testable import SomeLibrary
import XCTest
import Foundation

final class SomeLibraryTests: XCTestCase {

  func testIntentionallyFailingTest() {
    XCTAssertEqual(Library(name: "Some name").name, "Wrong name")
  }
}
