import Foundation

let RED = "\u{001B}[0;31m"
let GREEN = "\u{001B}[0;32m"
let BYEL = "\u{001B}[1;33m"
let UCYN = "\u{001B}[4;36m"
let RESET = "\u{001B}[0;0m"

// Error number 
enum Errno: Int32 {
    case generic = 1
    case broken
    case fewArgs, repoInfo, prefix, commitFile
    case invalidURL, invalidResponse, invalidIssuesCount 
    case gitRemote, gitURL, gitMalformedURL
    case todo, count
}

struct ShellCmd {
    var code: Int32 = 0
    var output: String = ""
    var success: Bool {
        get { return self.code == 0 }
    }

    init(_ code: Int32, _ output: String) {
        self.code = code
        self.output = output
    }
}

func shell(_ command: String) -> ShellCmd {
    let task = Process()
    let pipe = Pipe()

    task.standardInput = nil
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/bash")

    var data = Data()
    var output = ""
    do {
        try task.run()
        task.waitUntilExit()
        data = (try pipe.fileHandleForReading.readToEnd()) ?? Data()
    } catch {
        crash(error.localizedDescription)
    }

    output = String(data: data, encoding: .utf8) ?? ""
    return ShellCmd(task.terminationStatus, output)
}

func getEnv(_ name: String) -> String {
    let env = ProcessInfo.processInfo.environment
    return env[name] ?? ""
}

func query(_ url: URLRequest) async throws -> (Data, URLResponse) {
    try await URLSession.shared.data(for: url)
}

// Helper function that crashes the application
func crash(_ message: String, _ code: Errno) -> Never {
    print("fatal: \(message): \(errnoMsg(code))")
    exit(code.rawValue)
}

// Helper function that crashes the application
func crash(_ message: String) -> Never {
    print("fatal: \(message)")
    exit(Errno.generic.rawValue)
}

// Helper function that crashes the application
func crash(_ code: Errno) -> Never {
    print("fatal: \(errnoMsg(code))")
    exit(code.rawValue)
}

func warn(_ msg: String, note: String = "") -> Void {
    print("warning: \(msg)")
    if !note.isEmpty { print("note: \(note)") }
}

private func errnoMsg(_ code: Errno) -> String {
    assert(Errno.count.rawValue == 14, "ERROR: Errno enum messages not fully handled.")
    switch code {
    case .generic:
        return "A generic error occured."
    case .broken:
        return "Internal error. The programmer is terrible."
    case .fewArgs:
        return "Not enough arguments provided."
    case .repoInfo:
        return "Repository specified doesn't match <owner>/<repository>."
    case .prefix:
        return "Comment prefix cannot be empty."
    case .commitFile:
        return "Unable to find '.issues.todo'."
    case .invalidURL:
        return "Invalid Github URL"
    case .invalidResponse:
        return "Invalid Github Response"
    case .invalidIssuesCount:
        return "GitHub API returned a different number of issues."
    case .gitRemote:
        return "Unable to fetch git remote name."
    case .gitURL:
        return "Unable to fetch git remote URL."
    case .gitMalformedURL:
        return "Remote URL is malformed."
    case .todo:
        return "Not implemented yet."
    default:
        return ""
    }
}
