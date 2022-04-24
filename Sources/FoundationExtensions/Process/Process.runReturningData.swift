import Foundation

extension Process {
  
  public func runReturningData() throws -> Data? {
    
    let stdOut = Pipe()
    self.standardOutput = stdOut
    self.standardError = FileHandle.standardError
    
    try self.run()
    self.waitUntilExit()
    
    if let terminationError = terminationError {
      throw terminationError
    } else {
      return try stdOut.fileHandleForReading.readToEnd()
    }
  }
  
  public func runReturningData() async throws -> Data? {
    
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) in
      let stdOut = Pipe()
      self.standardOutput = stdOut
      self.standardError = FileHandle.standardError
      
      self.terminationHandler = { process in
        
        if let terminationError = process.terminationError {
          continuation.resume(throwing: terminationError)
        } else {
          do {
            let stdOutData = try stdOut.fileHandleForReading.readToEnd()
            continuation.resume(with: .success(stdOutData))
          } catch {
            continuation.resume(with: .failure(error))
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
