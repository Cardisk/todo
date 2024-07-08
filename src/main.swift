import Foundation

// Global variables
let fileManager = FileManager()
let jsonDecoder = JSONDecoder()
var settings: Settings

// Parsing settings from 'todo.json'
if fileManager.fileExists(atPath: "todo.json") {
    let data = File("todo.json").content.data(using: .utf8)!
    settings = try! jsonDecoder.decode(Settings.self, from: data)
} else {
    settings = Settings()
}

// Command line arguments
var args = CommandLine.arguments

// Validating args 
args.removeFirst()
if args.count == 0 { crash(.few_args) }

switch args.first ?? "" {
default:
    var files: [File] = []   
    for arg in args {
        let f = File(arg)
        files.append(f)
    }

    for f in files {
        f.isolateTodos(settings.prefix)
    }
}
