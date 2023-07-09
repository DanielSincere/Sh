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
  
  init(label: String, qos: DispatchQoS.QoSClass = .userInitiated) {

    self.queue = DispatchQueue(
      label: label,
      target: DispatchQueue.global(qos: qos)
    )

    self.pipe.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      self.append(nextData)
    }
  }
  
  func append(_ more: Data) {
    queue.async {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func closeReturningData() -> Data {

    self.pipe.fileHandleForReading.readabilityHandler = nil

    let value = queue.sync {
      self.buffer
    }

    self.buffer = Data()

    return value
  }
}
