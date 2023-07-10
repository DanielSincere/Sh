import Foundation

class PipeBuffer {
  enum StreamID: String {
    case stdOut, stdErr
  }
  
  let pipe = Pipe()
  private var buffer: Data = .init()
  private let queue: DispatchQueue

  private let semaphore = DispatchGroup()
  private let lock = NSLock()
  
  convenience init(id: StreamID, qos: DispatchQoS.QoSClass = .userInitiated) {
    self.init(label: id.rawValue, qos: qos)
  }
  
  init(label: String, qos: DispatchQoS.QoSClass = .userInitiated) {

    self.queue = DispatchQueue(
      label: label,
      target: DispatchQueue.global(qos: qos)
    )

    self.pipe.fileHandleForReading.readabilityHandler = { handler in
      self.semaphore.enter()
      let data = handler.availableData
      self.buffer.append(contentsOf: data)
      self.semaphore.leave()
    }
  }

  func closeReturningData() -> Data {
    let result = self.semaphore.wait(timeout: .now() + 1.1)
    switch result {
    case .success:
      print("SUCCESS")
    case .timedOut:
      print("TIME OUT")
    }

    return queue.sync {
      self.semaphore.wait()
      let data = self.buffer
      self.buffer = Data()
      self.pipe.fileHandleForReading.readabilityHandler = nil
      return data
    }
  }
}
