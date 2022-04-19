import Foundation

extension Process {
  
  public typealias AllOutput = (stdOut: Data?, stdErr: Data?, terminationError: TerminationError?)
  
  public func runReturningAllOutput() throws -> AllOutput {
    let stdOut = Pipe()
    let stdErr = Pipe()
    self.standardOutput = stdOut
    self.standardError = stdErr
    
    try self.run()
    self.waitUntilExit()
    
    let stdOutData = try stdOut.fileHandleForReading.readToEnd()
    let stdErrData = try stdErr.fileHandleForReading.readToEnd()
    return (stdOut: stdOutData, stdErr: stdErrData, terminationError: terminationError)
  }
  
  public func runReturningAllOutput() async throws -> AllOutput {
    try await withCheckedThrowingContinuation  { (continuation: CheckedContinuation<AllOutput, Error>) in
      let stdOut = Pipe()
      let stdErr = Pipe()
      self.standardOutput = stdOut
      self.standardError = stdErr
      
      self.terminationHandler = { process in
        
        do {
          let stdOutData = try stdOut.fileHandleForReading.readToEnd()
          let stdErrData = try stdErr.fileHandleForReading.readToEnd()
          continuation.resume(with: .success((stdOutData, stdErrData, process.terminationError)))
        } catch {
          continuation.resume(with: .failure(error))
        }
      }
      
      do {
        try self.run()
      } catch {
        continuation.resume(with: .failure(error))
      }
    }
  }
}
