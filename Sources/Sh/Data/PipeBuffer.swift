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

    pipe.fileHandleForReading.readabilityHandler = { handler in
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

    let value = queue.sync {
      self.buffer
    }
    
    self.buffer = Data()
    self.pipe.fileHandleForReading.readabilityHandler = nil

    return value
  }
}
