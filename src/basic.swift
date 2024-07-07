// Error number 
enum Errno: Int32 {
    case generic = 1
    case few_args, command, todo
    case count
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

private func errnoMsg(_ code: Errno) -> String {
    assert(Errno.count.rawValue == 5, "ERROR: Errno enum messages not fully handled.")
    switch code {
        case .generic:
            return "A generic error occured."
        case .few_args:
            return "Not enough arguments provided."
        case .command:
            return "Unknown command provided."
        case .todo:
            return "Not implemented yet."
        default:
            return ""
    }
}
