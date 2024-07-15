import Foundation

// Global variables
let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()
var settings: Settings = if File.exists("todo.json") {
    try! jsonDecoder.decode(Settings.self, from: File("todo.json").contentData)
} else {
    Settings()
}

// Command line arguments
var args = CommandLine.arguments

let commands: [String: () -> Void] = [
    "-h": help,
    "help": help,
    "-s": store,
    "store": store,
    "-c": commit, 
    "commit": commit, 
]

func help() -> Void {
    print("""
    USAGE: 
        
        todo [ -s | store ] [ -c | commit ] [ -h | help ] <file> ...

    OPTIONS:

        [ -s | store ] <file> ...
            store the issues on a temporary file
        
        [ -c | commit ]
            commit the issues saved on the temporary file
        
        [ -h | help ]
            show this help message

    """)
}

// doesn't modify the file, just save the issues
// as binaries
func store() -> Void {
    if args.isEmpty { crash(.fewArgs) }
    todo(commitToFile: false)
}

// read the issues as binaries and apply the changes
// then send the issue on github
func commit() -> Void {
    do {
        let data = try File(".todo_issues").contentData
        let issues: [Issue] = try jsonDecoder.decode([Issue].self, from: data)
        for issue in issues { print(issue) }
    } catch { crash(error.localizedDescription) }
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
        else { 
            do {
                let data = try jsonEncoder.encode(issues)
                try data.write(to: URL(fileURLWithPath: ".todo_issues"))
            } catch {
                crash(error.localizedDescription)
            }
        }
    }
}

// Validating args 
args.removeFirst()
if args.isEmpty { crash(.fewArgs) }

switch args.first ?? "" {
case let cmd where commands.keys.contains(cmd):
    args.removeFirst()
    commands[cmd]!()

default:
    todo()
}
