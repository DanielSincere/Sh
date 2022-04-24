import Foundation
import FoundationExtensions

struct InternalRepresetation {
  let announcer: Announcer?
  let params: Params
  
  func runRedirectingAllOutput(to sink: Sink) throws {
    announcer?.runRedirectingAllOutput(to: sink, params.cmd)
    try Process(params).runRedirectingAllOutput(to: sink)
  }
  
  func runRedirectingAllOutput(to sink: Sink) async throws {
    announcer?.runRedirectingAllOutput(to: sink, params.cmd)
    try await Process(params).runRedirectingAllOutput(to: sink)
  }
  
  
  func runReturningAllOutput() throws -> Process.AllOutput {
    announcer?.runReturningAllOutput(params.cmd)
    return try Process(params).runReturningAllOutput()
  }
  
  func runReturningAllOutput() async throws -> Process.AllOutput {
    announcer?.runReturningAllOutput(params.cmd)
    return try await Process(params).runReturningAllOutput()
  }
  
  
  func runReturningData() throws -> Data? {
    announcer?.runReturningData(params.cmd)
    return try Process(params).runReturningData()
  }
  
  func runReturningData() async throws -> Data? {
    announcer?.runReturningData(params.cmd)
    return try await Process(params).runReturningData()
  }
  
  
  func runReturningTrimmedString() throws -> String? {
    announcer?.runReturningTrimmedString(params.cmd)
    return try Process(params).runReturningTrimmedString()
  }
  
  func runReturningTrimmedString() async throws -> String? {
    announcer?.runReturningTrimmedString(params.cmd)
    return try await Process(params).runReturningTrimmedString()
  }
  
  func runDecoding<D: Decodable>(_ type: D.Type, using jsonDecoder: JSONDecoder = .init()) throws -> D {
    announcer?.runDecoding(type, params.cmd)
    let decoded = try Process(params).runReturningData()?.asJSON(decoding: type, using: jsonDecoder)
    if let decoded = decoded {
      return decoded
    } else {
      throw Errors.unexpectedNilDataError
    }
  }
}

extension InternalRepresetation {
  init(announcer: Announcer?,
       cmd: String,
       environment: [String: String],
       workingDirectory: String?) {
    self.init(announcer: announcer, params: .init(cmd, environment: environment, workingDirectory: workingDirectory))
  }
}
