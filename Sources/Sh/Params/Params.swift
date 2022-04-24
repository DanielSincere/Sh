import Foundation
import FoundationExtensions

public struct Params {
  public let cmd: String
  public let environment: [String: String]
  public let workingDirectory: String?
  
  public init(_ cmd: String, environment: [String: String] = [:], workingDirectory: String? = nil) {
    self.cmd = cmd
    self.environment = environment
    self.workingDirectory = workingDirectory
  }
}

extension Process {
  public convenience init(_ params: Params) {
    self.init(cmd: params.cmd,
              environment: params.environment,
              workingDirectory: params.workingDirectory)
  }
}
