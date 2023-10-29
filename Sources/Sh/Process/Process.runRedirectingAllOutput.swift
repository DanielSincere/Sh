import Foundation

#if os(Linux)
import SystemPackage
#else
import System
#endif

extension Process {

  public func runRedirectingAllOutput(to sink: Sink) throws {
    try self.redirectAllOutput(to: sink)
    try self.run()
    self.waitUntilExit()
    if let terminationError = terminationError {
      throw terminationError
    }
  }
  
  public func runRedirectingAllOutput(to sink: Sink) async throws {
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
    case .split(let out, err: let err):
      try self.redirectAllOutputToFiles(out: out, err: err)
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
  
  private func createFile(atPath path: String) throws -> FileHandle {
    let directories = FilePath(path).lexicallyNormalized().removingLastComponent()
    try FileManager.default.createDirectory(atPath: directories.string, withIntermediateDirectories: true)
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
    return fileHandle
  }
  
  private func redirectAllOutputToFile(path: String) throws {
    let fileHandle = try self.createFile(atPath: path)
    self.standardError = fileHandle
    self.standardOutput = fileHandle
  }
  
  private func redirectAllOutputToFiles(out: String, err: String) throws {
    self.standardOutput = try self.createFile(atPath: out)
    self.standardError = try self.createFile(atPath: err)
  }
}
