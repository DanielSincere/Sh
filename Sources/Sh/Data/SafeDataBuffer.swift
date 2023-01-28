import Foundation

class SafeDataBuffer {
  private var data = Data()
  private let queue = DispatchQueue(label: "Sh-SafeDataBuffer")
  
  func append(_ more: Data) async {
    await withCheckedContinuation({ continuation in
      queue.async {
        self.data.append(more)
        continuation.resume()
      }
    })
  }
  
  func appendSync(_ more: Data) {
    queue.async {
      self.data.append(more)
    }
  }
  
  func getData() async -> Data {
    await withCheckedContinuation({ continuation in
      queue.sync {
        continuation.resume(returning: self.data)
      }
    })
  }
  }
