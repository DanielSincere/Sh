import Foundation
import FoundationExtensions

extension InternalRepresetation {
  
  func runRedirectingAllOutput(to sink: Sink) throws {
    announcer?.runRedirectingAllOutput(to: sink, params.cmd)
    try Process(params).runRedirectingAllOutput(to: sink)
  }
  
  func runRedirectingAllOutput(to sink: Sink) async throws {
    announcer?.runRedirectingAllOutput(to: sink, params.cmd)
    try await Process(params).runRedirectingAllOutput(to: sink)
  }
}
