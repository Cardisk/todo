struct Issue {
    var titleIndex: Range<String.Index>
    var title: String
    var body: String

    init(_ titleIndex: Range<String.Index>,_ title: String, _ body: String) {
        self.titleIndex = titleIndex
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
