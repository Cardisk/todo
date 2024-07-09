import Foundation

class File {
    var path: String
    
    var content: String
    var data: Data?

    private var comments: [String]
    var todos: [String]
    var fixmes: [String]

    init(_ path: String) {
        self.path = path
        self.content = 
            (try? String(contentsOfFile: path)) ?? ""
        self.data = self.content.data(using: .utf8)
        self.comments = []
        self.todos = []
        self.fixmes = []
    }

    static func exists(_ path: String) -> Bool {
        return FileManager().fileExists(atPath: path)
    }

    private func isolateComments(_ prefix: String) -> Void {
        let lines = self.content.split(separator: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines) 
            if trimmed.hasPrefix(prefix) {
                self.comments.append(trimmed)
            }
        }
    }

    func isolateTodos(_ prefix: String) -> Void {
        self.isolateComments(prefix)

        // false = todo, true = fixme
        var lastInsertion: Bool = false
        for line in self.comments {
            switch line {
            case let l where l.hasPrefix("\(prefix) TODO:"):
                self.todos.append(l)
                lastInsertion = false
            case let l where l.hasPrefix("\(prefix) FIXME:"):
                self.fixmes.append(l)
                lastInsertion = true 
            default:
                lastInsertion ? 
                    self.fixmes.append(line) : self.todos.append(line) 
                continue
            }
        }
    } 
}
