import Foundation

extension Process {
  public var terminationError: TerminationError? {
    if self.terminationStatus == 0 {
      return nil
    }
    
    return TerminationError(process: self)
  }
}

public struct TerminationError: Error, LocalizedError {
  public let status: Int32
  public let reason: Reason

  public enum Reason {
    case exit, uncaughtSignal, unknownDefault
  }
  
  public var errorDescription: String? {
    switch reason {
    case .exit:
      return "Exited with code \(status)."
    case .uncaughtSignal:
      return "Uncaught signal, exited with code \(status)."
    case .unknownDefault:
      return "Unknown termination reason, exited with code \(status)."
    }
  }
}

private extension TerminationError {
  init(process: Process) {
    self.status = process.terminationStatus
    self.reason = process.terminationReason.reason
  }
}

private extension Process.TerminationReason {
  var reason: TerminationError.Reason {
    switch self {
    case .exit:
      return .exit
    case .uncaughtSignal:
      return .uncaughtSignal
#if !os(Linux)
    @unknown default:
      return .unknownDefault
#endif
    }
  }
}
