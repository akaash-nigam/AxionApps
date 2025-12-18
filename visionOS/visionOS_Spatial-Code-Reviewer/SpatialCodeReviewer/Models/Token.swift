//
//  Token.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

struct Token: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let tokenType: String
    let scope: String?

    var isExpired: Bool {
        return Date() >= expiresAt
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case tokenType = "token_type"
        case scope
    }
}

// MARK: - OAuth Provider

enum AuthProvider: String, CaseIterable {
    case github = "github"
    case gitlab = "gitlab"
    case bitbucket = "bitbucket"

    var name: String {
        switch self {
        case .github: return "GitHub"
        case .gitlab: return "GitLab"
        case .bitbucket: return "Bitbucket"
        }
    }

    var iconName: String {
        switch self {
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .gitlab: return "chevron.left.forwardslash.chevron.right"
        case .bitbucket: return "chevron.left.forwardslash.chevron.right"
        }
    }
}
