import Foundation

struct GithubIssue: Codable {
    let number: Int
    let title: String
    let body: String
}

struct Github {
    private var token: String
    private var owner: String
    private var repo: String
    private var request: URLRequest

    init(_ settings: Settings) {
        self.token = getEnv("GITHUB_TOKEN") 

        if settings.repo.isEmpty {

            let remote = shell("git remote")
            if !remote.success { crash(.gitRemote) }
            let url = shell("git remote get-url --all \(remote.output)")
            if !url.success { crash(.gitURL) }

            let info = url.output.components(separatedBy: "/")
            if info.isEmpty || info.count < 2 { crash(.gitMalformedURL) }

            self.owner = info[info.count - 2] 
            var repo = info.last!
            repo.replace(".git", with: "")
            self.repo = repo.trimmingCharacters(in: .whitespacesAndNewlines)

        } else {

            if !settings.repo.contains("/") { crash(.repoInfo) }
            let info = settings.repo.components(separatedBy: "/")
            if info.count != 2 { crash(.repoInfo) }

            if info[0].isEmpty { crash(.repoInfo) }
            self.owner = info[0]

            if info[1].isEmpty { crash(.repoInfo) }
            self.repo = info[1]

        }
        
        let urlString = "https://api.github.com/repos/\(self.owner)/\(self.repo)/issues"
        guard let url = URL(string: urlString) else {
            crash(urlString, .invalidURL)
        }

        self.request = URLRequest(url: url)

        self.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        self.request.addValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        self.request.addValue("token \(self.token)", forHTTPHeaderField: "Authorization")
    }

    mutating func getIssues() async -> [GithubIssue] {
        var githubIssues: [GithubIssue] = []

        self.request.httpMethod = "GET"
        self.request.httpBody = nil

        do {
            let (data, response) = try await query(self.request)

            guard let code = response as? HTTPURLResponse, 200 ~= code.statusCode else {
                crash("Github.getIssues: \(self.request.url!.path())", .invalidResponse)
            }

            githubIssues = try JSONDecoder().decode([GithubIssue].self, from: data)
        } catch {
            crash(error.localizedDescription)
        } 

        return githubIssues
    }

    mutating func postIssues(_ issues: [Issue]) async -> [GithubIssue] {
        var githubIssues: [GithubIssue] = []

        self.request.httpMethod = "POST"

        do {
            for issue in issues {
                self.request.httpBody = issue.data
                let (data, response) = try await query(self.request)
                
                guard let code = response as? HTTPURLResponse, 201 ~= code.statusCode else {
                    crash("Github.postIssues: response \(response) at \(self.request.url!.path())", .invalidResponse)
                }

                let githubIssue = try JSONDecoder().decode(GithubIssue.self, from: data)
                githubIssues.append(githubIssue)
            }
        } catch {
            crash(error.localizedDescription)
        }

        return githubIssues
    }
}
