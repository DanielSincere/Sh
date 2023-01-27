// shq.swift
//
// Public functions for general use.
// These are the quiet versions of the functions in `sh.swift`

import Foundation

/// Run a shell command. Useful for obtaining small bits of output
/// from a shell program
///
/// Does not announce the command it is about to execute.
/// To get an announcement, use `sh`
///
/// Arguments:
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
///
/// Returns:
/// - `String?` of whatever is in the standard output buffer.
///     Calls `.trimmingCharacters(in: .whitespacesAndNewlines)` 
///
public func shq(_ cmd: String,
                environment: [String: String] = [:],
                workingDirectory: String? = nil) throws -> String?  {
  return try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runReturningData()?
    .asTrimmedString()
}

public func shq(_ cmd: String,
                environment: [String: String] = [:],
                workingDirectory: String? = nil) async throws -> String?  {
  return try await Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runReturningData()?
    .asTrimmedString()
}


/// Run a shell command, and parse the output as JSON
///
public func shq<D: Decodable>(_ type: D.Type,
                              decodedBy jsonDecoder: JSONDecoder = .init(),
                              _ cmd: String,
                             environment: [String: String] = [:],
                             workingDirectory: String? = nil) throws -> D {
  let decoded = try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runReturningData()?
    .asJSON(decoding: type, using: jsonDecoder)
  
  if let decoded = decoded {
    return decoded
  } else {
    throw Errors.unexpectedNilDataError
  }
}

/// Asynchronously, run a shell command, and parse the output as JSON
///
public func shq<D: Decodable>(_ type: D.Type,
                              decodedBy jsonDecoder: JSONDecoder = .init(),
                              _ cmd: String,
                             environment: [String: String] = [:],
                             workingDirectory: String? = nil) async throws -> D {
  let decoded = try await Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runReturningData()?
    .asJSON(decoding: type, using: jsonDecoder)
  
  if let decoded = decoded {
    return decoded
  } else {
    throw Errors.unexpectedNilDataError
  }
}

/// Run a shell command, sending output to the terminal or a file.
/// Useful for long running shell commands like `xcodebuild`
///
/// Does not announce the command it is about to execute.
/// To get an announcement, use `sh`
///
/// Arguments:
/// - `sink` where to redirect output to, either `.terminal` or `.file(path)`
/// - `cmd` the shell command to run
/// - `environment` a dictionary of enviroment variables to merge
///     with the enviroment of the current `Process`
/// - `workingDirectory` the directory where to run the command
///
public func shq(_ sink: Sink,
                _ cmd: String,
                environment: [String: String] = [:],
                workingDirectory: String? = nil) throws {
  try Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runRedirectingAllOutput(to: sink)
}

public func shq(_ sink: Sink,
                _ cmd: String,
                environment: [String: String] = [:],
                workingDirectory: String? = nil) async throws {
  try await Process(cmd: cmd, environment: environment, workingDirectory: workingDirectory)
    .runRedirectingAllOutput(to: sink)
}
