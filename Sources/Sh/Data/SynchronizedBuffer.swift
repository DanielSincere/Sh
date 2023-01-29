import Foundation

class SynchronizedBuffer<T: RangeReplaceableCollection> {
  
  private var buffer = T()
  private let queue: DispatchQueue
  
  init(label: String) {
    queue = DispatchQueue(label: label)
  }
  
  func append(_ more: T) {
    queue.async {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func yieldValue(block: @escaping (T) -> Void) {
    queue.sync {
      let value = self.buffer
      block(value)
    }
  }
  
  var unsafeValue: T {
    buffer
  }
}
