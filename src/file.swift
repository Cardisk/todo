import Foundation

class File {
    var path: String
    var content: String

    init(_ path: String) {
        self.path = path
        self.content = 
            (try? String(contentsOfFile: path)) ?? ""
    }
}
