// Helper function that crashes the application
func crash(_ message: String) -> Never {
    print("todo: Fatal error: \(message)")
    exit(1)
}

// Command line arguments
var args = CommandLine.arguments

// Validating args 
args.removeFirst()
if args.count == 0 { crash("Not enough arguments provided.") }
