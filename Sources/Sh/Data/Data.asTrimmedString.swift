import Foundation

extension Data {
  
  public func asTrimmedString(encoding: String.Encoding = .utf8) -> String? {
    String(data: self, encoding: encoding)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
