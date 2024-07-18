import Foundation

class File {
    var path: String
    var commentPrefix: String
    var commentPostfix: String
    
    var content: String
    var contentData: Data 

    init(_ path: String, _ commentPrefix: String = "//", _ commentPostfix: String = "") {
        self.path = path

        if commentPrefix.isEmpty { crash(.prefix) }
        self.commentPrefix = commentPrefix

        self.commentPostfix = commentPostfix

        do {
            self.content = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            crash(error.localizedDescription)
        }

        self.contentData = self.content.data(using: .utf8)!
    }

    static func exists(_ path: String) -> Bool {
        return FileManager().fileExists(atPath: path)
    }

    func issues() -> [Issue] {
        let fileLines = self.content.split(separator: "\n")
        if fileLines.isEmpty { return [] }

        let todo  = "TODO:"
        let fixme = "FIXME:"
        let issue = "ISSUE"

        var hotComments: [String] = []
        var hasHotPrefix = false
        for line in fileLines {
            var l = String(line)
            l = l.trimmingCharacters(in: .whitespacesAndNewlines)

            if !l.hasPrefix(self.commentPrefix) { 
                hasHotPrefix = false
                continue 
            }

            l.removeFirst(self.commentPrefix.count)
            l.removeLast(self.commentPostfix.count)
            l = l.trimmingCharacters(in: .whitespacesAndNewlines)

            if l.hasPrefix(issue) { 
                hasHotPrefix = false
                continue 
            }

            if l.hasPrefix(todo) || l.hasPrefix(fixme) {
                hasHotPrefix = true
            }

            if !hasHotPrefix { continue }

            hotComments.append(l)
        }
        
        var issues: [Issue] = []

        var i = 0
        while i < hotComments.count {
            if !hotComments[i].hasPrefix(todo) && !hotComments[i].hasPrefix(fixme) {
                crash(.broken)
            }
            
            var prefix = ""

            if hotComments[i].hasPrefix(todo) { prefix = todo }
            if hotComments[i].hasPrefix(fixme) { prefix = fixme }
            
            let rawTitle = hotComments[i]

            // removing the prefix
            hotComments[i].removeFirst(prefix.count)
            
            let title = hotComments[i].trimmingCharacters(in: .whitespacesAndNewlines)
            i += 1

            var body = ""
            while i < hotComments.count 
                        && !hotComments[i].hasPrefix(todo) 
                            && !hotComments[i].hasPrefix(fixme) {
                body += hotComments[i] + "\n"
                i += 1
            }
            // now the i index is pointing to the next prefixed comment 
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
