import Foundation

/// A `Params` struct reprensents the parameters to execute a shell command
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
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
