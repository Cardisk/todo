// Error number 
enum Errno: Int32 {
    case generic = 1
    case broken
    case fewArgs, command, todo
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
    assert(Errno.count.rawValue == 6, "ERROR: Errno enum messages not fully handled.")
    switch code {
        case .generic:
            return "A generic error occured."
        case .broken:
            return "Internal error. The programmer is terrible."
        case .fewArgs:
            return "Not enough arguments provided."
        case .command:
            return "Unknown command provided."
        case .todo:
            return "Not implemented yet."
        default:
            return ""
    }
}
