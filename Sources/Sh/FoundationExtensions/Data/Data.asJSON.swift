import Foundation

extension Data {
 
  public func asJSON<D: Decodable>(decoding type: D.Type, using jsonDecoder: JSONDecoder = .init()) throws -> D {
    try jsonDecoder.decode(type, from: self)
  }
}
