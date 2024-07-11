import Foundation

// Global variables
let jsonDecoder = JSONDecoder()
var settings: Settings = if File.exists("todo.json") {
    try! jsonDecoder.decode(Settings.self, from: File("todo.json").data!)
} else {
    Settings()
}

// Command line arguments
var args = CommandLine.arguments

let commands: [String: () -> Void] = [
    "-s": store, 
    "-c": commit, 
]

// doesn't modify the file, just save the issues
// as binaries
func store() -> Void {
    todo(commitToFile: false)
}

// read the issues as binaries and apply the changes
// then send the issue on github
func commit() -> Void {
    crash("commit command", .todo)
}

func todo(commitToFile: Bool = true) {
    var files: [File] = []   
    for arg in args {
        do {
            let f = try File(arg, settings.prefix, settings.postfix)
            files.append(f)
        } catch { crash(error.localizedDescription) }
    }

    for f in files {
        f.isolateTodos()
        var issues = f.makeIssues()
        var i = 0
        while i < issues.count {
            print(issues[i])
            let prompt = "[ \(GREEN)a\(RESET)dd / \(RED)D\(RESET)ISCARD ] > "
            print(prompt, terminator: "")
            let choice = readLine(strippingNewline: true) ?? ""
            switch choice.first {
            case "a":
                i += 1
            default:
                issues.remove(at: i)
            }
            print()
        }

        if commitToFile { f.commitIssues(issues) }
        else { crash("saving issues as binaries", .todo) }
    }
}

// Validating args 
args.removeFirst()
if args.count == 0 { crash(.fewArgs) }

switch args.first ?? "" {
case let cmd where commands.keys.contains(cmd):
    args.removeFirst()
    commands[cmd]!()

default:
    todo()
}
