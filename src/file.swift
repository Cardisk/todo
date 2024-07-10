import Foundation

class File {
    var path: String
    
    var content: String
    var data: Data? {
        get { content.data(using: .utf8) }
    }

    private var comments: [String]
    var todos: [(Range<String.Index>, String)]
    var fixmes: [(Range<String.Index>, String)]

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

            // taking the position of the comment inside the file
            let range = self.content.range(of: line)!
            print(self.content[range])
            switch line {
            case let l where l.hasPrefix("TODO:"):
                self.todos.append((range, l))
                lastInsertion = false
            case let l where l.hasPrefix("FIXME:"):
                self.fixmes.append((range, l))
                lastInsertion = true 
            default:
                lastInsertion ? 
                    self.fixmes.append((range, line)) : self.todos.append((range, line)) 
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
            if !self.todos[i].1.hasPrefix("TODO:") {
                crash(.broken)
            }
            
            // getting the range of TODO:...
            let range = self.todos[i].0

            // removing the TODO: prefix
            self.todos[i].1.removeFirst(5)
            
            let title = self.todos[i].1.trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while i < self.todos.count && !self.todos[i].1.hasPrefix("TODO:") {
                body += self.todos[i].1 + "\n"
                i += 1
            }
            // now the i index is pointing to the next TODO
            body = body.trimmingCharacters(in: .whitespacesAndNewlines)

            issues.append(Issue(range, title, body))
        }

        // processing fixmes 
        i = 0
        while i < self.fixmes.count {
            if !self.fixmes[i].1.hasPrefix("FIXME:") {
                crash(.broken)
            }
            
            // getting the range of FIXME:...
            let range = self.fixmes[i].0
            
            // removing the FIXME: prefix
            self.fixmes[i].1.removeFirst(6)
            
            let title = self.fixmes[i].1.trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while i < self.fixmes.count && !self.fixmes[i].1.hasPrefix("FIXME:") {
                body += self.fixmes[i].1 + "\n"
                i += 1
            }
            // now the i index is pointing to the next TODO
            body = body.trimmingCharacters(in: .whitespacesAndNewlines)

            issues.append(Issue(range, title, body))
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
            self.content.replaceSubrange(issue.titleIndex.lowerBound..<issue.titleIndex.upperBound, with: line)
        }

        print("\n" + self.content)
        crash(.todo)
    }
}
