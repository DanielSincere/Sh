import Foundation
import Darwin

public func std(_ command: String) throws {
  var pid: Int32 = 0
  let args = ["/bin/sh", "-c", command]
  let argv: [UnsafeMutablePointer<CChar>?] = args.map{ $0.withCString(strdup) }
  defer {
    for case let arg? in argv {
      free(arg)
    }
  }
  if posix_spawn(&pid, argv[0], nil, nil, argv + [nil], environ) < 0 {
    throw SpawnError()
  }

  var status: Int32 = 0
  _ = waitpid(pid, &status, 0)
  if status != 0 {
    throw StdError(exitCode: status)
  }
}


public func std(_ command: String) async throws {
  try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
    var pid: Int32 = 0
    let args = ["/bin/sh", "-c", command]
    let argv: [UnsafeMutablePointer<CChar>?] = args.map{ $0.withCString(strdup) }
    defer {
      for case let arg? in argv {
        free(arg)
      }
    }
    if posix_spawn(&pid, argv[0], nil, nil, argv + [nil], environ) < 0 {
      continuation.resume(throwing: SpawnError())
    }

    var status: Int32 = 0
    _ = waitpid(pid, &status, 0)
    if status != 0 {
      continuation.resume(throwing: StdError(exitCode: status))
    } else {
      continuation.resume()
    }
  }
}

public struct SpawnError: LocalizedError {
  public var errorDescription: String? = "Unable to spawn subprocess"
}

public struct StdError: Error {
  public let exitCode: Int32
}
