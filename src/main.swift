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
