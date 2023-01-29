import Foundation

class SynchronizedBuffer<T: RangeReplaceableCollection> {
  
  private var buffer = T()
  private let queue: DispatchQueue
  
  init(label: String) {
    queue = DispatchQueue(label: label)
  }
  
  func append(_ more: T) {
    queue.sync {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func data(block: (T) -> Void) {
    queue.sync(flags: .barrier) {
      let value = self.buffer
      block(value)
    }
  }
  
  var unsafeValue: T {
    buffer
  }
}
