import Foundation

extension Process {
  
  public typealias AllOutput = (stdOut: Data,
                                stdErr: Data,
                                terminationError: TerminationError?)
  
  public func runReturningAllOutput() throws -> AllOutput {
    let queue = DispatchQueue(label: "Sh-runReturningAllOutput")
    
    let stdOut = Pipe()
    var stdOutData = Data()
    self.standardOutput = stdOut
    stdOut.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      queue.sync {
        stdOutData.append(nextData)
      }
    }
    
    let stdErr = Pipe()
    var stdErrData = Data()
    self.standardError = stdErr    
    stdErr.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      queue.sync {
        stdErrData.append(nextData)
      }
    }

    try self.run()
    self.waitUntilExit()
    
    return (stdOut: stdOutData, stdErr: stdErrData, terminationError: terminationError)
  }
  
  public func runReturningAllOutput() async throws -> AllOutput {
    
    let stdOutData = SafeDataBuffer()
    let stdOut = Pipe()
    self.standardOutput = stdOut
    stdOut.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      stdOutData.append(nextData)
    }

    let stdErrData = SafeDataBuffer()
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
