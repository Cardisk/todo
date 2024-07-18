import Foundation

// Global variables
let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()
let settings: Settings = if File.exists("todo.json") {
    try! jsonDecoder.decode(Settings.self, from: File("todo.json").contentData)
} else {
    Settings()
}
var github = Github(settings)

// Command line arguments
var args = CommandLine.arguments
var issueCollection: [(File, [Issue])] = []

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

func store() -> Void {
    if args.isEmpty { crash(.fewArgs) }
    todo(commitToFile: false)
}

func commit() -> Void {
    do {
        let data = File(".todoIssues").contentData
        let issues: [Issue] = try jsonDecoder.decode([Issue].self, from: data)
        for issue in issues { print(issue) }
    } catch { crash(error.localizedDescription) }
}

func todo(commitToFile: Bool = true) {
    var files: [File] = []   
    for arg in args {
        let f = File(arg, settings.prefix, settings.postfix)
        files.append(f)
    }

    for f in files {
        var issues = f.issues()
        var i = 0
        print()
        while i < issues.count {
            print(issues[i])
            let prompt = "    [ \(GREEN)a\(RESET)dd / \(RED)D\(RESET)ISCARD ] > "
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

        if issues.isEmpty { continue }
        issueCollection.append((f, issues))
    }

    var jsonData: Data = Data()
    for ic in issueCollection {
        if commitToFile {
            // <file>.commitIssues(<issues>)
            ic.0.commitIssues(ic.1)
        } else {
            do {
                let data = try jsonEncoder.encode(ic.1)
                jsonData += data
            } catch {
                crash(error.localizedDescription)
            }
        }
    }

    if !jsonData.isEmpty {
        do {
            try jsonData.write(to: URL(fileURLWithPath: ".todoIssues"))
        } catch {
            crash(error.localizedDescription)
        }
    }
}


func main() -> Never {
    // Validating args 
    args.removeFirst()
    if args.isEmpty { crash(.fewArgs) }

    switch args.first! {
    case let cmd where commands.keys.contains(cmd):
        args.removeFirst()
        commands[cmd]!()

    default:
        todo()
    }

    exit(0)
}

main()
