import Foundation

struct Settings: Decodable {
    var url: String
    var prefix: String
    var postfix: String

    init() {
        self.url = ""
        self.prefix = "//"
        self.postfix = ""
    }
}
