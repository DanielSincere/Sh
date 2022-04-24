import Foundation

extension Process {
  
  public func runRedirectingStreams(to sink: Sink) throws {
    try self.redirectAllOutput(to: sink)
    try self.run()
    self.waitUntilExit()
    if let terminationError = terminationError {
      throw terminationError
    }
  }
  
  public func runRedirectingStreams(to sink: Sink) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      do {
        try self.redirectAllOutput(to: sink)
      } catch {
        continuation.resume(throwing: error)
        return
      }
      
      self.terminationHandler = { process in
        if let terminationError = process.terminationError {
          continuation.resume(throwing: terminationError)
        } else {
          continuation.resume()
        }
      }
      
      do {
        try self.run()
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
  
  private func redirectAllOutput(to sink: Sink) throws {
    switch sink {
    case .terminal:
      self.redirectAllOutputToTerminal()
    case .file(path: let path):
      try self.redirectAllOutputToFile(path: path)
    case .null:
      self.redirectAllOutputToNullDevice()
    }
  }
  
  private func redirectAllOutputToTerminal() {
    self.standardOutput = FileHandle.standardOutput
    self.standardError = FileHandle.standardError
  }
  
  private func redirectAllOutputToNullDevice() {
    self.standardOutput = FileHandle.nullDevice
    self.standardError = FileHandle.nullDevice
  }
  
  private func redirectAllOutputToFile(path: String) throws {
    
    guard FileManager.default.createFile(atPath: path, contents: Data()) else {
      struct CouldNotCreateFile: Error {
        let path: String
      }
      throw CouldNotCreateFile(path: path)
    }
    
    guard let fileHandle = FileHandle(forWritingAtPath: path) else {
      struct CouldNotOpenFileForWriting: Error {
        let path: String
      }
      throw CouldNotOpenFileForWriting(path: path)
    }
    
    self.standardError = fileHandle
    self.standardOutput = fileHandle
  }
}
