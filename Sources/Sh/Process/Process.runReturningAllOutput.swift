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
    
    let stdErr = Pipe()
    var stdErrData = Data()
    self.standardError = stdErr
    

    
#if !os(Linux)
    stdOut.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      queue.sync {
        stdOutData.append(nextData)
      }
    }
    
    stdErr.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      queue.sync {
        stdErrData.append(nextData)
      }
    }
#endif
    
    try self.run()
    
#if os(Linux)
    queue.sync {
      stdOutData = stdOut.fileHandleForReading.readDataToEndOfFile()
      stdErrData = stdErr.fileHandleForReading.readDataToEndOfFile()
    }
#endif
    self.waitUntilExit()
    
    return (stdOut: stdOutData, stdErr: stdErrData, terminationError: terminationError)
  }
  
  public func runReturningAllOutput() async throws -> AllOutput {
    let stdOutData = DataHolder()
    let stdErrData = DataHolder()
    return try await withCheckedThrowingContinuation  { (continuation: CheckedContinuation<AllOutput, Error>) in
      
      let stdOut = Pipe()
      self.standardOutput = stdOut
      
      let stdErr = Pipe()
      self.standardError = stdErr
      
#if !os(Linux)
      stdOut.fileHandleForReading.readabilityHandler = { handler in
        let nextData = handler.availableData
        Task {
          await stdOutData.append(nextData)
        }
      }
      stdErr.fileHandleForReading.readabilityHandler = { handler in
        let nextData = handler.availableData
        Task {
          await stdErrData.append(nextData)
        }
      }
#endif
      
      
      self.terminationHandler = { process in
        let maybeTerminationError = process.terminationError
        Task {
          
          continuation.resume(returning: (await stdOutData.data,
                                          await stdErrData.data,
                                          maybeTerminationError))
          
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
