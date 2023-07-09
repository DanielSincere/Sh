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
      self.queue.async {
        let nextData = handler.availableData
        self.buffer.append(contentsOf: nextData)
      }
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
