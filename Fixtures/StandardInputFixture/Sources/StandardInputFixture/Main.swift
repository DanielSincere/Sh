import Sh

@main
struct Main {

  static func main() async throws {
    try await std("touch tempfile.tmp")
    try await std("rm -i tempfile.tmp")
  }
}
