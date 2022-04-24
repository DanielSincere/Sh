import Foundation
import FoundationExtensions

extension InternalRepresetation {
  
  func runDecoding<D: Decodable>(_ type: D.Type, using jsonDecoder: JSONDecoder = .init()) throws -> D {
    announcer?.runDecoding(type, params.cmd)
    let decoded = try Process(params).runReturningData()?.asJSON(decoding: type, using: jsonDecoder)
    if let decoded = decoded {
      return decoded
    } else {
      throw Errors.unexpectedNilDataError
    }
  }
  
  func runDecoding<D: Decodable>(_ type: D.Type, using jsonDecoder: JSONDecoder = .init()) async throws -> D {
    announcer?.runDecoding(type, params.cmd)
    let decoded = try await Process(params).runReturningData()?.asJSON(decoding: type, using: jsonDecoder)
    if let decoded = decoded {
      return decoded
    } else {
      throw Errors.unexpectedNilDataError
    }
  }
}
