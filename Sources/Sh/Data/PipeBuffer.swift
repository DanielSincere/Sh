import Foundation

class PipeBuffer {
  enum StreamID: String {
    case stdOut, stdErr
  }
  
  let pipe = Pipe()
  private var buffer: Data = .init()

  convenience init(id: StreamID) {
    self.init(label: id.rawValue)
  }
  
  init(label: String) {
    self.pipe.fileHandleForReading.readabilityHandler = { handle in
      let data = handle.availableData
      self.buffer.append(contentsOf: data)
    }
  }


  func closeReturningData() throws -> Data {

    var value = self.buffer
    self.pipe.fileHandleForReading.readabilityHandler = nil
    let data = try self.pipe.fileHandleForReading.readToEnd() ?? Data()

    value.append(data)

    self.buffer = Data()

    return value
  }
}
