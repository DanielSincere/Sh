import Foundation

enum StreamID: String {
  case stdOut, stdErr
}

class PipeBuffer {

  let pipe = Pipe()
  let buffer: SynchronizedBuffer<Data>
  
  convenience init(id: StreamID) {
    self.init(label: id.rawValue)
  }
  
  init(label: String) {
    self.buffer = SynchronizedBuffer(label: label)
    pipe.fileHandleForReading.readabilityHandler = { handler in
      let nextData = handler.availableData
      self.buffer.append(nextData)
    }
  }
  

}
