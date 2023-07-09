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
      let data = handler.availableData
      self.append(data: data)
    }
  }

  func append(data: Data) {
    self.queue.async {
      self.buffer.append(contentsOf: data)
    }
  }

  func closeReturningData() -> Data {
    let value = queue.sync {
      self.buffer
    }

    self.pipe.fileHandleForReading.readabilityHandler = nil
    self.buffer = Data()

    return value
  }
}
