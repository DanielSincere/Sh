import Foundation

extension InternalRepresetation {
  public enum Errors: Error, LocalizedError {
    case unexpectedNilDataError
    
    public var errorDescription: String? {
      switch self {
      case .unexpectedNilDataError:
        return "Expected data, but there wasn't any"
      }
    }
  }
}
