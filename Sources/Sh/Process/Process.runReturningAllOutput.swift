import Foundation

extension Process {
  
  public struct AllOutput {
    public let stdOut: Data,
        stdErr: Data,
        terminationError: TerminationError?
  }
  
  public func runReturningAllOutput() throws -> AllOutput {
        
    let stdOut = PipeBuffer(id: .stdOut)
    self.standardOutput = stdOut.pipe
    
    let stdErr = PipeBuffer(id: .stdErr)
    self.standardError = stdErr.pipe
    
    try self.run()
    self.waitUntilExit()

    return AllOutput(stdOut: stdOut.closeReturningData(),
            stdErr: stdErr.closeReturningData(),
            terminationError: terminationError)
  }
  
  public func runReturningAllOutput() async throws -> AllOutput {
    
    let stdOut = PipeBuffer(id: .stdOut)
    self.standardOutput = stdOut.pipe
    
    let stdErr = PipeBuffer(id: .stdErr)
    self.standardError = stdErr.pipe
    
    return try await withCheckedThrowingContinuation  { (continuation: CheckedContinuation<AllOutput, Error>) in
      
      self.terminationHandler = { process in
        let maybeTerminationError = process.terminationError
        
        let stdErrData = stdErr.closeReturningData()
        let stdOutData = stdOut.closeReturningData()


        continuation.resume(returning: AllOutput(stdOut: stdOutData,
                                                 stdErr: stdErrData,
                                                 terminationError: maybeTerminationError))
      }
      
      do {
        try self.run()
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
