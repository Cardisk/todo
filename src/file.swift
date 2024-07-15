import Foundation

class File {
    var path: String
    var commentPrefix: String
    var commentPostfix: String
    
    var content: String
    var contentData: Data {
        get { content.data(using: .utf8)! }
    }

    private var comments: [String]
    var todos: [String]
    var fixmes: [String]

    init(_ path: String, _ commentPrefix: String = "",
                            _ commentPostfix: String = "") throws {
        self.path = path
        self.commentPrefix = commentPrefix
        self.commentPostfix = commentPostfix

        self.content = try String(contentsOfFile: path, encoding: .utf8)

        self.comments = []
        self.todos = []
        self.fixmes = []
    }

    static func exists(_ path: String) -> Bool {
        return FileManager().fileExists(atPath: path)
    }

    private func isolateComments() -> Void {
        let lines = self.content.split(separator: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines) 
            if trimmed.hasPrefix(self.commentPrefix) {
                self.comments.append(trimmed)
            }
        }
    }

    func isolateTodos() -> Void {
        self.isolateComments()

        // false = todo, true = fixme
        var lastInsertion: Bool = false
        var issueFound: Bool = false
        for c in self.comments {
            var line: String = c 
            line.removeFirst(self.commentPrefix.count)
            line.removeLast(self.commentPostfix.count)
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)

            switch line {
            case let l where l.hasPrefix("TODO:"):
                self.todos.append(l)
                lastInsertion = false
                issueFound = false
            case let l where l.hasPrefix("FIXME:"):
                self.fixmes.append(l)
                lastInsertion = true 
                issueFound = false
            case let l where l.hasPrefix("ISSUE:"):
                issueFound = true
                continue
            default:
                if issueFound { continue }
                lastInsertion ? 
                    self.fixmes.append(line) : self.todos.append(line) 
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
            
            let rawTitle = self.todos[i]

            // removing the TODO: prefix
            self.todos[i].removeFirst(5)
            
            let title = self.todos[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while i < self.todos.count && !self.todos[i].hasPrefix("TODO:") {
                body += self.todos[i] + "\n"
                i += 1
            }
            // now the i index is pointing to the next TODO
            body = body.trimmingCharacters(in: .whitespacesAndNewlines)

            issues.append(Issue(self.path, title, rawTitle, body))
        }

        // processing fixmes 
        i = 0
        while i < self.fixmes.count {
            if !self.fixmes[i].hasPrefix("FIXME:") {
                crash(.broken)
            }
            
            let rawTitle = self.fixmes[i]
            
            // removing the FIXME: prefix
            self.fixmes[i].removeFirst(6)
            
            let title = self.fixmes[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while i < self.fixmes.count && !self.fixmes[i].hasPrefix("FIXME:") {
                body += self.fixmes[i] + "\n"
                i += 1
            }
            // now the i index is pointing to the next TODO
            body = body.trimmingCharacters(in: .whitespacesAndNewlines)

            issues.append(Issue(self.path, title, rawTitle, body))
        }

        return issues
    }

    func commitIssues(_ issues: [Issue]) -> Void {
        for issue in issues {
            var line = "ISSUE: \(issue.title) \(self.commentPostfix)"
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let range = self.content.range(of: issue.rawTitle)!
            self.content.replaceSubrange(range, with: line)
        }

        do {
            try self.contentData.write(to: URL(fileURLWithPath: self.path))
        } catch { crash(.write) }
    }
}
