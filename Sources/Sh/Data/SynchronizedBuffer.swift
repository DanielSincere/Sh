import Foundation

class SynchronizedBuffer<T: RangeReplaceableCollection> {
  
  private var buffer = T()
  private let queue: DispatchQueue
  
  init(label: String) {
    queue = DispatchQueue(label: label)
  }
  
  func append(_ more: T) {
    queue.async(flags: .barrier) {
      self.buffer.append(contentsOf: more)
    }
  }
  
  func yieldValue(block: @escaping (T) -> Void) {
    queue.async(flags: .barrier) {
      let value = self.buffer
      block(value)
    }
  }
  
  var unsafeValue: T {
    buffer
  }
}
