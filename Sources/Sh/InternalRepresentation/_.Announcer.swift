import Rainbow
import Foundation

extension InternalRepresentation {
  struct Announcer {
    
    func runReturningTrimmedString(_ cmd: String) {
      announce("Running `\(cmd)`, returning trimmed `String`")
    }
    
    func runDecoding<D: Decodable>(_ type: D.Type, _ cmd: String) {
      announce("Running `\(cmd)`, decoding `\(type)`")
    }
    
    func runReturningAllOutput(_ cmd: String) {
      announce("Running `\(cmd)`, returning all output")
    }
    
    func runReturningData(_ cmd: String) {
      announce("Running `\(cmd)`, returning raw data")
    }
    
    func runRedirectingStreams(to sink: Sink, _ cmd: String) {
      switch sink {
      case .terminal:
        announce("Running `\(cmd)`")
      case .file(let path):
        announce("Running `\(cmd)`, logging to `\(path.blue)`")
      case .null:
        announce("Running `\(cmd)`, discarding output")
      }
    }
  }
}

private extension InternalRepresentation.Announcer {
  func announce(_ text: String) {
    ("[Sh] ".blue + text + "\n")
      .data(using: .utf8)
      .map(FileHandle.standardError.write)
  }
}
