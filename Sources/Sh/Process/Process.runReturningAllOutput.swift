import Foundation

extension Process {
  
  public typealias AllOutput = (stdOut: Data,
                                stdErr: Data,
                                terminationError: TerminationError?)
  
  public func runReturningAllOutput() throws -> AllOutput {
    
    let stdOut = Pipe()
    let stdOutData = SynchronizedBuffer<Data>()
    self.standardOutput = stdOut
    stdOut.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      stdOutData.append(nextData)
    }
    
    let stdErr = Pipe()
    let stdErrData = SynchronizedBuffer<Data>()
    self.standardError = stdErr
    stdErr.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      stdErrData.append(nextData)
    }

    try self.run()
    self.waitUntilExit()
    
    return (stdOut: stdOutData.unsafeValue,
            stdErr: stdErrData.unsafeValue,
            terminationError: terminationError)
  }
  
  public func runReturningAllOutput() async throws -> AllOutput {
    
    let stdOutData = SynchronizedBuffer<Data>()
    let stdOut = Pipe()
    self.standardOutput = stdOut
    stdOut.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      stdOutData.append(nextData)
    }

    let stdErrData = SynchronizedBuffer<Data>()
    let stdErr = Pipe()
    self.standardError = stdErr
    stdErr.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      stdErrData.append(nextData)
    }
    
    return try await withCheckedThrowingContinuation  { (continuation: CheckedContinuation<AllOutput, Error>) in
      
      self.terminationHandler = { process in
        let maybeTerminationError = process.terminationError

        Task {
          continuation.resume(returning: (await stdOutData.getData(),
                                          await stdErrData.getData(),
                                          maybeTerminationError))
        }
      }
      
      do {
        try self.run()
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
