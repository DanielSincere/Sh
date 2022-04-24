import Foundation

struct InternalRepresetation {
  let announcer: Announcer?
  let params: Params
}

extension InternalRepresetation {
  init(announcer: Announcer?,
       cmd: String,
       environment: [String: String],
       workingDirectory: String?) {
    self.init(announcer: announcer, params: .init(cmd, environment: environment, workingDirectory: workingDirectory))
  }
}
