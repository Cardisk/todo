import Foundation

struct Issue: Codable {
    var filePath: String
    var title: String
    var rawTitle: String
    var body: String
    var data: Data

    init(_ filePath: String, _ title: String, _ rawTitle: String, _ body: String) {
        self.filePath = filePath
        self.title = title
        self.rawTitle = rawTitle
        self.body = body

        let dict = [
            "title": self.title,
            "body": self.body,
        ]

        do {
            self.data = try JSONSerialization.data(withJSONObject: dict)
        } catch {
            self.data = Data()
        }
    }
}

extension Issue: CustomStringConvertible {
    var description: String {
        let txt = """
        \(BYEL)-- Issue:\(RESET)
        \(UCYN)file:\(RESET)
        \(self.filePath)
        \(UCYN)title:\(RESET)
        \(self.title)
        \(UCYN)body:\(RESET)
        \(self.body)

        """
        return txt 
    }
}
