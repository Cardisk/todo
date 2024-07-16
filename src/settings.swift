import Foundation

struct Settings: Decodable {
    var repo: String
    var prefix: String
    var postfix: String

    init() {
        self.repo = ""
        self.prefix = "//"
        self.postfix = ""
    }
}
