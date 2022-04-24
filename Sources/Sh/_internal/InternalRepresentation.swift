import Foundation

struct InternalRepresentation {
  let announcer: Announcer?
  let params: Params
}

extension InternalRepresentation {
  init(announcer: Announcer?,
       cmd: String,
       environment: [String: String],
       workingDirectory: String?) {
    self.init(announcer: announcer, params: .init(cmd, environment: environment, workingDirectory: workingDirectory))
  }
}
