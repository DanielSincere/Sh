/// `async`/`await` versions of functions in `shq(Params).swift`
///
import Foundation

/// Run a shell command. Useful for obtaining small bits of output
/// from a shell program with `async`/`await`
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
public func shq(_ params: Params) async throws -> String?  {
  try await
  InternalRepresetation(announcer: nil,
                        params: params)
  .runReturningTrimmedString()
}


/// Asynchronously, run a shell command, and parse the output as JSON
///
public func shq<D: Decodable>(_ type: D.Type,
                              using jsonDecoder: JSONDecoder = .init(),
                              _ params: Params) async throws -> D {
  try await
  InternalRepresetation(announcer: nil,
                        params: params)
  .runDecoding(type, using: jsonDecoder)
}

/// Asynchronously, run a shell command, and redirect the output
/// to the specified `Sink`
public func shq(_ sink: Sink,
                _ params: Params) async throws {
  try await
  InternalRepresetation(announcer: nil,
                        params: params)
  .runRedirectingAllOutput(to: sink)
}
