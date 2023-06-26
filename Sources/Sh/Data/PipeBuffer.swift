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
    queue.async {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func yieldValue(block: @escaping (Data) -> Void) {
    queue.sync {
      let value = self.buffer
      block(value)
      cleanup()
    }
  }

  func cleanup() {
    pipe.fileHandleForReading.readabilityHandler = nil
  }
  
  var unsafeValue: Data {
    buffer
  }
}
