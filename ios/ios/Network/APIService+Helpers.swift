//
//  APIService+Helpers.swift
//  ios
//
//  API Service Helper Extensions
//

import Foundation

extension APIService {
    /// Test the connection to the backend
    func checkHealth() async throws -> HealthResponse {
        return try await request(endpoint: "/health", method: "GET")
    }
}

// MARK: - Health Response Model

struct HealthResponse: Codable {
    let status: String
    let database: String
    let redis: String
    let celery: String
}

