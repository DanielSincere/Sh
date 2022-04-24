import Foundation

extension InternalRepresentation {
  
  func runRedirectingStreams(to sink: Sink) throws {
    announcer?.runRedirectingStreams(to: sink, params.cmd)
    try Process(params).runRedirectingStreams(to: sink)
  }
  
  func runRedirectingStreams(to sink: Sink) async throws {
    announcer?.runRedirectingStreams(to: sink, params.cmd)
    try await Process(params).runRedirectingStreams(to: sink)
  }
}
