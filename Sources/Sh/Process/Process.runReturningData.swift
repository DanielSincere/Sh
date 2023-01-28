import Foundation

extension Process {
  
  public func runReturningData() throws -> Data {
    
    let queue = DispatchQueue(label: "Sh-standardOutput")
    var data = Data()
    let pipe = Pipe()
    
    self.standardOutput = pipe
    self.standardError = FileHandle.standardError
    
#if !os(Linux)
    pipe.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      queue.async {
        data.append(nextData)
      }
    }
#endif
    
    try self.run()
    
#if os(Linux)
    queue.sync {
      data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    }
#endif
    
    self.waitUntilExit()
    
    if let terminationError = terminationError {
      throw terminationError
    } else {
      return data
    }
  }
  
  actor DataHolder {
    var data = Data()
    
    func append(_ more: Data) {
      self.data.append(more)
    }
  }
  
  public func runReturningData() async throws -> Data {   
    let dataHolder = DataHolder()
    
    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
      
      var data = Data()
      let pipe = Pipe()

      self.standardOutput = pipe
      self.standardError = FileHandle.standardError
      
#if !os(Linux)
      pipe.fileHandleForReading.readabilityHandler = { handler in
        let nextData = handler.availableData
        Task {
          await dataHolder.append(nextData)
        }
      }
#endif
      self.terminationHandler = { process in
        
        if let terminationError = process.terminationError {
          continuation.resume(throwing: terminationError)
        } else {
          Task {
            let data = await dataHolder.data
            continuation.resume(returning: data)
          }
        }
      }
      
      do {
        try self.run()
#if os(Linux)
        Task {
          let data = pipe.fileHandleForReading.readDataToEndOfFile()
          await dataHolder.append(data)
        }
#endif
      } catch {
        continuation.resume(with: .failure(error))
      }
    }
  }
}
