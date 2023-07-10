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
      return try stdOut.closeReturningData()
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
          do {
            let data = try stdOut.closeReturningData()
            continuation.resume(returning: data)
          } catch {
            continuation.resume(throwing: error)
          }
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
