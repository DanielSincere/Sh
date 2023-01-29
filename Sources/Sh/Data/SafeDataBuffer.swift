import Foundation

class SafeDataBuffer {
  private var data = Data()
  private let queue = DispatchQueue(label: "Sh-SafeDataBuffer")
  
  func append(_ more: Data) async {
    await withCheckedContinuation({ continuation in
      queue.sync {
        self.data.append(more)
        continuation.resume()
      }
    })
  }
  
  func append(_ more: Data) {
    queue.sync {
      self.data.append(more)
    }
  }
  
  func getData() async -> Data {
    await withCheckedContinuation({ continuation in
      queue.sync(flags: .barrier) {
        let data = self.data
        continuation.resume(returning: data)
      }
    })
  }
  
  var unsafeData: Data {
    data
  }
}
