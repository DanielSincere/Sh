import Foundation

extension Process {
  
  public convenience init(cmd: String, environment: [String: String] = [:], workingDirectory: String? = nil) {
    self.init()
    self.executableURL = URL(fileURLWithPath: "/bin/sh")
    self.arguments = ["-c", cmd]
    self.environment = ProcessInfo.processInfo.environment.combine(with: environment)
    if let workingDirectory = workingDirectory {
      self.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)
    }
  }

}

private extension Dictionary where Key == String, Value == String {
  
  func combine(with overrides: [String: String]?) -> [String: String] {
    guard let overrides = overrides else {
      return self
    }
    
    var result = self
    for pair in overrides {
      result[pair.key] = pair.value
    }
    return result
  }
}
