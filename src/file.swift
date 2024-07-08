import Foundation

class File {
    var path: String
    var content: String
    var todos: [String]
    var fixmes: [String]

    init(_ path: String) {
        self.path = path
        self.content = 
            (try? String(contentsOfFile: path)) ?? ""
        self.todos = []
        self.fixmes = []
    }

    func isolateTodos(_ prefix: String) -> Void {
        let lines = self.content.split(separator: "\n")

        for line in lines {
            switch line.trimmingCharacters(in: .whitespacesAndNewlines) {
            case let l where l.hasPrefix("\(prefix) TODO:"):
                self.todos.append(l)
            case let l where l.hasPrefix("\(prefix) FIXME:"):
                self.fixmes.append(l)
            default:
                continue
            }
        }
    } 
}
