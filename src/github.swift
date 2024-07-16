import Foundation

struct Github {
    private var token: String
    private var owner: String
    private var repo: String

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
    }

    func getIssues() -> Void {}

    func postIssues(_ issues: [Issue]) -> Void {}
}
