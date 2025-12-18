//
//  User.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let login: String
    let name: String?
    let email: String?
    let avatarURL: URL?
    let bio: String?
    let company: String?
    let location: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case email
        case avatarURL = "avatar_url"
        case bio
        case company
        case location
        case publicRepos = "public_repos"
        case followers
        case following
        case createdAt = "created_at"
    }
}

// MARK: - Mock Data

extension User {
    static let mock = User(
        id: 1,
        login: "octocat",
        name: "The Octocat",
        email: "octocat@github.com",
        avatarURL: URL(string: "https://github.com/octocat.png"),
        bio: "GitHub's mascot",
        company: "GitHub",
        location: "San Francisco",
        publicRepos: 8,
        followers: 100000,
        following: 0,
        createdAt: Date()
    )
}
