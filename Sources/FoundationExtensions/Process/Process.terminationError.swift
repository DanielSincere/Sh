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
  public let reason: String
  
  public var errorDescription: String? {
    "Ended with status \(status) with reason: \(reason)"
  }
}

private extension TerminationError {
  init(process: Process) {
    self.status = process.terminationStatus
    self.reason = process.terminationReason.errorDescription
  }
}

private extension Process.TerminationReason {
  var errorDescription: String {
    switch self {
    case .exit:
      return "`regular exit`"
    case .uncaughtSignal:
      return "`uncaught signal`"
#if !os(Linux)
    @unknown default:
      return "`unknown default Process.TerminationReason`"
#endif
    }
  }
}
