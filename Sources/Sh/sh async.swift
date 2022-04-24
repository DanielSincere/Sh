/// `async`/`await` versions of functions in `sh.swift`

import Foundation

/// Run a shell command. Useful for obtaining small bits of output
/// from a shell program with `async`/`await`.
///
/// Announces the command it is about to execute. To run quietly,
/// use `shq`
///
/// Arguments:
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
///
/// Returns:
/// - `String` of whatever is in the standard output buffer.
///     Uses `.trimmingCharacters(in: .whitespacesAndNewlines)`
public func sh(_ cmd: String,
               environment: [String: String] = [:],
               workingDirectory: String? = nil) async throws -> String? {
  try await
  InternalRepresentation(announcer: .init(),
                        cmd: cmd,
                        environment: environment,
                        workingDirectory: workingDirectory)
  .runReturningTrimmedString()
}

/// Run a shell command, and parse the output as JSON. `Async`/`await` version
///
/// Arguments
/// - `type` Decodable type to decode
/// - `using` JSONDecoder to use. Creates a new one by default
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
public func sh<D: Decodable>(_ type: D.Type,
                             using jsonDecoder: JSONDecoder = .init(),
                             _ cmd: String,
                             environment: [String: String] = [:],
                             workingDirectory: String? = nil) async throws -> D {
  try await
  InternalRepresentation(announcer: .init(),
                        cmd: cmd,
                        environment: environment,
                        workingDirectory: workingDirectory)
  .runDecoding(type, using: jsonDecoder)
}


/// `Async`/`await` version
/// Run a shell command, sending output to the terminal or a file.
/// Useful for long running shell commands like `xcodebuild`
///
/// Announces the command it is about to execute. To run quietly,
/// use `shq`
///
/// Arguments:
/// - `sink` where to redirect output to, either `.terminal` or `.file(path)`
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
///
public func sh(_ sink: Sink,
               _ cmd: String,
               environment: [String: String] = [:],
               workingDirectory: String? = nil) async throws {
  try await
  InternalRepresentation(announcer: .init(),
                        cmd: cmd,
                        environment: environment,
                        workingDirectory: workingDirectory)
  .runRedirectingAllOutput(to: sink)
}
