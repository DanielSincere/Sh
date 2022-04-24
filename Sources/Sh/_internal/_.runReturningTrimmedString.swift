import Foundation

extension InternalRepresetation {
  
  func runReturningTrimmedString() throws -> String? {
    announcer?.runReturningTrimmedString(params.cmd)
    return try Process(params).runReturningTrimmedString()
  }
  
  func runReturningTrimmedString() async throws -> String? {
    announcer?.runReturningTrimmedString(params.cmd)
    return try await Process(params).runReturningTrimmedString()
  }
}
