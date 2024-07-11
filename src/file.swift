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

            issues.append(Issue(title, rawTitle, body))
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

            issues.append(Issue(title, rawTitle, body))
        }

        return issues
    }

    func commitIssues(_ issues: [Issue]) -> Void {
        // TODO: loop over the issues and modify self.content.
        // At the end of this method, the File will overwrite itself.
        // -- self.content.replaceSubrange(index, with: "ISSUE: ")
        // -- try! self.data!.write(to: URL(fileURLWithPath: self.path))
        for issue in issues {
            let line = "ISSUE: \(issue.title)"
            let range = self.content.range(of: issue.rawTitle)!
            self.content.replaceSubrange(range, with: line)
        }

        if let data = self.data {
            do {
                try data.write(to: URL(fileURLWithPath: self.path))
            } catch { crash(.generic) }
        }
    }
}
