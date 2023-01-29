import Foundation

extension Process {
  
  public func runReturningData() throws -> Data {

    let stdOut = PipeBuffer(id: .stdOut)
    self.standardOutput = stdOut.pipe
    self.standardError = FileHandle.standardError
    
    try self.run()
    
    self.waitUntilExit()
    
    if let terminationError = terminationError {
      throw terminationError
    } else {
      return stdOut.buffer.unsafeValue
    }
  }
    
  public func runReturningData() async throws -> Data {   
    self.standardError = FileHandle.standardError
    
    let stdOut = PipeBuffer(id: .stdOut)
    self.standardOutput = stdOut.pipe
    
    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
      self.terminationHandler = { process in
        if let terminationError = process.terminationError {
          continuation.resume(throwing: terminationError)
        } else {
          Task {
            let data = await stdOut.buffer.getData()
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
