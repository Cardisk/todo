import Foundation

// Global variables
let jsonDecoder = JSONDecoder()
var settings: Settings = if File.exists("todo.json") {
    try! jsonDecoder.decode(Settings.self, from: File("todo.json").data!)
} else {
    Settings()
}

let commands: [String: ([String]) -> Void] = [
    "-s": store, 
    "-c": commit, 
]

// doesn't modify the file, just save the issues
// as binaries
func store(_ args: [String]) -> Void {
    crash("store command", .todo)
}

// read the issues as binaries and apply the changes
// then send the issue on github
func commit(_ args: [String]) -> Void {
    crash("commit command", .todo)
}

// Command line arguments
var args = CommandLine.arguments

// Validating args 
args.removeFirst()
if args.count == 0 { crash(.fewArgs) }

switch args.first ?? "" {
case let cmd where commands.keys.contains(cmd):
    args.removeFirst()
    commands[cmd]!(args)

default:
    var files: [File] = []   
    for arg in args {
        // TODO: need to handle non-existing files
        let f = File(arg, settings.prefix, settings.postfix)
        files.append(f)
    }

    for f in files {
        f.isolateTodos()
        let issues = f.makeIssues()
        for issue in issues {
            print(issue)
            let prompt = "[ \(GREEN)a\(RESET)dd / \(RED)D\(RESET)ISCARD ] > "
            print(prompt)
            let choice = readLine(strippingNewline: true) ?? ""
            switch choice.first {
            case "a":
                crash("Adding changes", .todo)
            default:
                crash("Discarding changes", .todo)
            }
        }
    }
}
