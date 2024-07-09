struct Issue {
    var title: String
    var body: String

    init(_ title: String, _ body: String) {
       self.title = title
       self.body = body
    }

    func toUrlQuery() -> String {
        var query = "?"
        query += "title=\(self.title)"
        query += "&"
        query += "body=\(self.body)"

        return query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
    }
}
