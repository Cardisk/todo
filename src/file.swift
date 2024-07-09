import Foundation

class File {
    var path: String
    
    var content: String
    var data: Data? {
        get { content.data(using: .utf8) }
    }

    private var comments: [String]
    var todos: [String]
    var fixmes: [String]

    init(_ path: String) {
        self.path = path
        self.content = 
            (try? String(contentsOfFile: path)) ?? ""
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
        for c in self.comments {
            var line: String = c 
            line.removeFirst(prefix.count)
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)

            switch line {
            case let l where l.hasPrefix("TODO:"):
                self.todos.append(l)
                lastInsertion = false
            case let l where l.hasPrefix("FIXME:"):
                self.fixmes.append(l)
                lastInsertion = true 
            default:
                lastInsertion ? 
                    self.fixmes.append(line) : self.todos.append(line) 
                continue
            }
        }
    } 
    
    func makeIssues() -> [Issue] {
        var issues: [Issue] = []
        var i: Int

        // processing todos
        i = 0
        while i < self.todos.count {
            if !self.todos[i].hasPrefix("TODO:") {
                crash(.broken)
            }
            
            // removing the TODO: prefix
            self.todos[i].removeFirst(5)
            
            let title = self.todos[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while !self.todos[i].hasPrefix("TODO:") {
                body += self.todos[i] + "\n"
            }

            issues.append(Issue(title, body))
            i += 1
        }

        // processing fixmes 
        i = 0
        while i < self.fixmes.count {
            if !self.fixmes[i].hasPrefix("FIXME:") {
                crash(.broken)
            }
            
            // removing the FIXME: prefix
            self.fixmes[i].removeFirst(6)
            
            let title = self.fixmes[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while !self.fixmes[i].hasPrefix("FIXME:") {
                body += self.fixmes[i] + "\n"
            }

            issues.append(Issue(title, body))
            i += 1
        }

        return issues
    }

}
