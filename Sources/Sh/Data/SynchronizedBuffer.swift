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
  
  func getData() async -> T {
    await withCheckedContinuation({ continuation in
      queue.sync(flags: .barrier) {
        let value = self.buffer
        continuation.resume(returning: value)
      }
    })
  }
  
  var unsafeValue: T {
    buffer
  }
}
