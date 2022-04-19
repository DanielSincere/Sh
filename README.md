# Sh

Who wants to use Bash or Ruby scripts to maintain your Swift project? Not me. Let's use Swift.

Sh lets you reason about your script in Swift, easily calling shell commands and using their output in your Swift program. Or when orchestrating a build script, simply redirect all output to the terminal, a log file, or `/dev/null`.

## Motivation

Bash scripts have gotten us pretty far, but it's difficult reasoning about control flow. And there's no type safety. Many command line tools already have decent interfaces, it's just the control flow of that could use some improvements. Sh solves this by relying on Swift control flow.

## Installation

Add Sh as a dependency in your `Package.swift`

```
  dependencies: [
    .package(url: "https://github.com/FullQueueDeveloper/Sh.git", from: "1.0.0"),
  ]
```

## Writing scripts:

### Fetching data from the shell

Here is a simple example, where we ask the shell for the date, formatted as seconds since 1970. We then parse a `Foundation.TimeInterval`, since it conforms to `Codable`. Last, we construct a `Data`, and print it.

    import Sh
    import Foundation

    let timeInterval = try sh(TimeInterval.self, "date +%s")
    let date = Date(timeIntervalSince1970: timeInterval)
    print("The date is \(date).")

A more substantial example might query `op` or `lpass` for a secret, or query `terraform output` for information about our infrastructure, or query Apple's `agvtool` for Apple version info of our Xcode project.

### Long running scripts

This file might live in `scripts/Sources/pre-commit/main.swift`. Perhaps we want to run our tests, and confirm that the release build succeeds as well. Perhaps we want to see the output of `swift test` in our terminal so we can react to it, but we don't really care to immediately see any release build output, happy to send it to a log file.

    import Sh
    import Foundation

    try sh(.terminal, "swift test")
    try sh(.file("logs/build.log"), "swift build -c release")

## Architecture

Sh adds convenience extensions to `Foundation.Process`.

### Construction

Sh makes it easier to construct a `Foundation.Process`.

    init(cmd: String, environment: [String: String] = [:], workingDirectory: String? = nil)

### Run

Sh makes it easier to run a `Process`. The basic method runs the process, and returns whatever is in standard output as a `Data?`

    func runReturningData() throws -> Data?

Sh adds some helper methods that build on this. `runReturningTrimmedString` parses the `Data` as a `String` and trims the whitespace.

    try Process("echo hello").runReturningTrimmedString() // returns "hello"

Sh can also parse JSON output. Given a simple `struct`:

    struct Simple: Decodable {
      let greeting: String
    }

We can parse the output like this:

    let simple = try sh(Simple.self, #"echo '{"greeting": "hello"}'"#)
    print(simple.greeting) // prints "hello"

## Async/await

Yes, Sh supports Swift's `async`/`await`. All methods have a corresponding `async` version.

## Goals:

- Enable calling command line tools easily from Swift, since Swift offers a nicer type system than Bash or Zsh.
- Allow easy variable substitution in shell calls, and what was run in the shell can be announced to the terminal, for easy copy-paste

## Related Projects

This package by itself does not try to provide a domain specific language for various tools. But there is a growing list of Sh-powered wrappers that offer a nicer API for some command line tools.

- [ShGit](https://github.com/FullQueueDeveloper/ShGit) for a Sh wrapper around Git.
- [Sh1Password](https://github.com/FullQueueDeveloper/Sh1Password) for a Sh wrapper around 1Password's CLI version 2.
