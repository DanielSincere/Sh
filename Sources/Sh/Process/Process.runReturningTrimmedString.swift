import Foundation

public extension Process {

  func runReturningTrimmedString() throws -> String? {
    try runReturningData()?.asTrimmedString()
  }

  func runReturningTrimmedString() async throws -> String? {
    try await runReturningData()?.asTrimmedString()
  }
}
