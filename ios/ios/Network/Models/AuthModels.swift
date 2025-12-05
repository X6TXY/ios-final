//
//  AuthModels.swift
//  ios
//
//  Authentication Data Models
//

import Foundation

// MARK: - Request Models

struct SignupRequest: Codable {
    let email: String
    let username: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

// MARK: - Response Models

struct TokenPair: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

struct User: Codable {
    let id: String
    let email: String
    let username: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Handle UUID as string
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            id = uuid.uuidString
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}

// MARK: - Error Model

struct APIError: Codable, Error {
    let detail: String
}

