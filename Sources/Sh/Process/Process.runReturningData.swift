import Foundation

extension Process {
  
  public func runReturningData() throws -> Data {
    
    let data = SafeDataBuffer()
    let pipe = Pipe()
    
    self.standardOutput = pipe
    self.standardError = FileHandle.standardError
    
    pipe.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      data.append(nextData)
    }
    
    try self.run()
    
    self.waitUntilExit()
    
    if let terminationError = terminationError {
      throw terminationError
    } else {
      return data.unsafeData
    }
  }
    
  public func runReturningData() async throws -> Data {   

    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
      let dataBuffer = SafeDataBuffer()
      let pipe = Pipe()

      self.standardOutput = pipe
      self.standardError = FileHandle.standardError
      
      pipe.fileHandleForReading.readabilityHandler = { handler in
        let nextData = handler.availableData
        dataBuffer.append(nextData)
      }

      self.terminationHandler = { process in
        
        if let terminationError = process.terminationError {
          continuation.resume(throwing: terminationError)
        } else {
          Task {
            let data = await dataBuffer.getData()
            continuation.resume(returning: data)
          }
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
