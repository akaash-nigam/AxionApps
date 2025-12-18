//
//  Repository.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

struct Repository: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let owner: Owner
    let description: String?
    let isPrivate: Bool
    let htmlURL: URL
    let cloneURL: URL
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let defaultBranch: String
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    let topics: [String]
    let hasWiki: Bool
    let hasIssues: Bool
    let hasProjects: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case description
        case isPrivate = "private"
        case htmlURL = "html_url"
        case cloneURL = "clone_url"
        case language
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case defaultBranch = "default_branch"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case topics
        case hasWiki = "has_wiki"
        case hasIssues = "has_issues"
        case hasProjects = "has_projects"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fullName = try container.decode(String.self, forKey: .fullName)
        owner = try container.decode(Owner.self, forKey: .owner)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        htmlURL = try container.decode(URL.self, forKey: .htmlURL)
        cloneURL = try container.decode(URL.self, forKey: .cloneURL)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        forksCount = try container.decode(Int.self, forKey: .forksCount)
        openIssuesCount = try container.decode(Int.self, forKey: .openIssuesCount)
        defaultBranch = try container.decode(String.self, forKey: .defaultBranch)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        pushedAt = try container.decodeIfPresent(Date.self, forKey: .pushedAt)
        topics = try container.decodeIfPresent([String].self, forKey: .topics) ?? []
        hasWiki = try container.decodeIfPresent(Bool.self, forKey: .hasWiki) ?? false
        hasIssues = try container.decodeIfPresent(Bool.self, forKey: .hasIssues) ?? false
        hasProjects = try container.decodeIfPresent(Bool.self, forKey: .hasProjects) ?? false
    }

    init(
        id: Int,
        name: String,
        fullName: String,
        owner: Owner,
        description: String?,
        isPrivate: Bool,
        htmlURL: URL,
        cloneURL: URL,
        language: String?,
        stargazersCount: Int,
        forksCount: Int,
        openIssuesCount: Int,
        defaultBranch: String,
        createdAt: Date,
        updatedAt: Date,
        pushedAt: Date?,
        topics: [String] = [],
        hasWiki: Bool = false,
        hasIssues: Bool = false,
        hasProjects: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.description = description
        self.isPrivate = isPrivate
        self.htmlURL = htmlURL
        self.cloneURL = cloneURL
        self.language = language
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.openIssuesCount = openIssuesCount
        self.defaultBranch = defaultBranch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pushedAt = pushedAt
        self.topics = topics
        self.hasWiki = hasWiki
        self.hasIssues = hasIssues
        self.hasProjects = hasProjects
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }

    struct Owner: Codable, Hashable {
        let login: String
        let id: Int
        let avatarURL: URL?

        enum CodingKeys: String, CodingKey {
            case login
            case id
            case avatarURL = "avatar_url"
        }
    }
}

// MARK: - Mock Data

extension Repository {
    static let mock = Repository(
        id: 1296269,
        name: "Hello-World",
        fullName: "octocat/Hello-World",
        owner: Owner(
            login: "octocat",
            id: 1,
            avatarURL: URL(string: "https://github.com/octocat.png")
        ),
        description: "My first repository on GitHub!",
        isPrivate: false,
        htmlURL: URL(string: "https://github.com/octocat/Hello-World")!,
        cloneURL: URL(string: "https://github.com/octocat/Hello-World.git")!,
        language: "JavaScript",
        stargazersCount: 1000,
        forksCount: 100,
        openIssuesCount: 5,
        defaultBranch: "main",
        createdAt: Date(),
        updatedAt: Date(),
        pushedAt: Date()
    )

    static let mockList: [Repository] = [
        mock,
        Repository(
            id: 2,
            name: "example-repo",
            fullName: "octocat/example-repo",
            owner: Owner(login: "octocat", id: 1, avatarURL: URL(string: "https://github.com/octocat.png")),
            description: "An example repository",
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/octocat/example-repo")!,
            cloneURL: URL(string: "https://github.com/octocat/example-repo.git")!,
            language: "TypeScript",
            stargazersCount: 500,
            forksCount: 50,
            openIssuesCount: 3,
            defaultBranch: "main",
            createdAt: Date(),
            updatedAt: Date(),
            pushedAt: Date()
        )
    ]
}
