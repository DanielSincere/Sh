import Foundation

class SynchronizedBuffer<T: RangeReplaceableCollection> {
  private var buffer = T()
  private let queue = DispatchQueue(label: "Sh-SafeDataBuffer")
  
  func append(_ more: T) async {
    await withCheckedContinuation({ continuation in
      queue.sync {
        self.buffer.append(contentsOf: more)
        continuation.resume()
      }
    })
  }
  
  func append(_ more: T) {
    queue.sync {
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
