import Foundation

struct Sh {
  let announcer: Announcer?
  let cmd: String
  let environment: [String: String]
  let workingDirectory: String?
  
  func runRedirectingAllOutput(to sink: Sink) throws {
    announcer?.runRedirectingAllOutput(to: sink, cmd)
    
    try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
      .runRedirectingAllOutput(to: sink)
  }
  
  func runRedirectingAllOutput(to sink: Sink) async throws {
    announcer?.runRedirectingAllOutput(to: sink, cmd)
    
    try await Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
      .runRedirectingAllOutput(to: sink)
  }
  
  
  func runReturningAllOutput() throws -> Process.AllOutput {
    announcer?.runReturningAllOutput(cmd)
    
    return try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
      .runReturningAllOutput()
  }
  
  func runReturningData() throws -> Data? {
    announcer?.runReturningData(cmd)
    
    return try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
      .runReturningData()
  }
  
  func runReturningTrimmedString() throws -> String? {
    announcer?.runReturningTrimmedString(cmd)
    
    return try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
      .runReturningTrimmedString()
  } 
}
