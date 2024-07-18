import Foundation

// JSON serializers
let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()

// application settings
var settings = Settings()

if FileManager().fileExists(atPath: "todo.json") {
     do {
         settings = try jsonDecoder.decode(Settings.self, 
                                 from: File("todo.json").contentData)
     } catch {
         crash(error.localizedDescription)
     }
}

// available commands list
let commands: [String: ([String]) -> Void] = [
    "-h": help,
    "help": help,

    "-s": store,
    "store": store,

    "-c": commit,
    "commit": commit,

    "-g": get,
    "get": get,
]

// commands functions
func help(_ args: [String]) -> Void {
    print("""
    NAME:
            todo - utility to handle TODOs and FIXMEs

    USAGE:
            todo [ -h | help   ] [ -s | store  ] 
                 [ -c | commit ] [ -g | get    ] <file> ...

    DESCRIPTION:
            Todo is a command line utility to process TODOs and FIXMEs inside
            the file[s] provided as argument[s].
            If no option is provided, the program will be executed in its
            entirety.
            But what exactly does this program do?
            It will scan the file[s] searching TODOs and FIXMEs, then it asks 
            the user to add or discard them interactively. 
            Based on which command is being executed, the program handles
            issues differently (see OPTIONS below).
            At the end of the process, only accepted issues will be posted on
            GitHub and TODOs and FIXMEs are replaced with ISSUE.

    OPTIONS:
            [ -h | help   ]
                Show this message

            [ -s | store  ]
                Skip the GitHub posting and store the result into '.todoIssues'

            [ -c | commit ]
                Read the issues from '.todoIssues' and post them onto GitHub
                Also changes the interested file[s]

            [ -g | get    ]
                Display all the issues found on GitHub
    """)
}

func store(_ args: [String]) -> Void {
    if args.isEmpty { crash(.fewArgs) }
    // TODO: implement here
    crash(.todo)
}

func commit(_ args: [String]) -> Void {
    // TODO: implement here
    crash(.todo)
}

func get(_ args: [String]) -> Void {
    // TODO: implement here
    crash(.todo)
}

// application functions
func files(_ args: [String]) -> [File] {
    var files: [File] = []

    for arg in args {
        let file = File(arg, settings.prefix, settings.postfix)
        files.append(file)
    }

    return files
}

func issues(_ files: [File]) -> [Issue] {
    var issues: [Issue] = []
    
    for file in files {
        let fileIssues = file.issues()
        if !fileIssues.isEmpty { issues.append(contentsOf: fileIssues) }
    }

    return issues
}

func user(_ issues: inout [Issue]) -> Void {
    if issues.isEmpty { return }

    var i = 0
    let prompt = "    [ \(GREEN)a\(RESET)dd / \(RED)D\(RESET)ISCARD ] > "
    
    print()
    
    while i < issues.count {
        print(issues[i])
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
}

func post(_ issues: [Issue]) async -> [GithubIssue] {
    var handle = await Github(settings)
    let githubIssues = await handle.postIssues(issues)
    return githubIssues
}

func modify(_ files: [File], _ issues: [Issue]) -> Void {
    for file in files {
        var fileIssues: [Issue] = []
        for issue in issues {
            if file.path != issue.filePath { continue }
            fileIssues.append(issue)
        }
        if !fileIssues.isEmpty { file.commitIssues(fileIssues) }
    }
}

func main() async -> Never {
    // command line arguments
    var args = CommandLine.arguments
    // removing program name
    args.removeFirst()
    // nothing provided
    if args.isEmpty { crash(.fewArgs) }
    

    // safe unwrap, already validated
    switch args.first! {
    case let cmd where commands.keys.contains(cmd):
        // removing the command
        args.removeFirst()
        // safe unwrap, already validated
        commands[cmd]!(args)

    default:
        let files = files(args)
        var issues = issues(files)
        user(&issues)

        if issues.isEmpty {
            print("Nothing to do here...")
            exit(0)
        }

        let githubIssues = await post(issues)

        if issues.count != githubIssues.count { crash(.invalidIssuesCount) }
        var i = 0
        while i < issues.count {
            issues[i].number = githubIssues[i].number
            i += 1
        }

        modify(files, issues)

        if !issues.isEmpty {
            print("Issue", terminator: "")
            print(issues.count > 1 ? "s " : " ", terminator: "")
            print("submitted!")
        }
    }

    exit(0)
}

await main()
