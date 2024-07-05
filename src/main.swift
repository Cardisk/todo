enum Errno: Int32 {
    case few_args = 1
}

// Helper function that crashes the application
func crash(_ message: String, _ code: Errno) -> Never {
    print("Fatal error: \(message)")
    exit(code.rawValue)
}

// Command line arguments
var args = CommandLine.arguments

// Validating args 
args.removeFirst()
if args.count == 0 { crash("Not enough arguments provided.", .few_args) }
