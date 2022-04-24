import Foundation

public func sh(_ params: Params) throws -> String? {
  try InternalRepresetation(announcer: .init(), params: params)
    .runReturningTrimmedString()
}

public func sh(_ params: Params) async throws -> String? {
  try await InternalRepresetation(announcer: .init(), params: params)
    .runReturningTrimmedString()
}
