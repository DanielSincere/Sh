import Foundation

class PipeBuffer {
  enum StreamID: String {
    case stdOut, stdErr
  }
  
  let pipe = Pipe()
  private var buffer: Data = .init()
  private let queue: DispatchQueue
  
  convenience init(id: StreamID) {
    self.init(label: id.rawValue)
  }
  
  init(label: String) {
    self.queue = DispatchQueue(label: label)
    pipe.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      self.buffer.append(nextData)
    }
  }
  
  func append(_ more: Data) {
    queue.sync {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func yieldValueAndClose(block: @escaping (Data) -> Void) {
    queue.sync {
      let value = self.buffer
      block(value)
      pipe.fileHandleForReading.readabilityHandler = nil
      buffer = Data()
    }
  }
  
  var unsafeValue: Data {
    buffer
  }
}
