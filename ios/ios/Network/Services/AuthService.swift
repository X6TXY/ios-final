//
//  AuthService.swift
//  ios
//
//  Authentication Service
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private let apiService = APIService.shared
    private let keychain = KeychainManager.shared
    
    private init() {}
    
    // MARK: - Auth Token Storage
    
    var accessToken: String? {
        get {
            return keychain.getString(forKey: "access_token")
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: "access_token")
            } else {
                keychain.delete(forKey: "access_token")
            }
        }
    }
    
    var refreshToken: String? {
        get {
            return keychain.getString(forKey: "refresh_token")
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: "refresh_token")
            } else {
                keychain.delete(forKey: "refresh_token")
            }
        }
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil
    }
    
    // MARK: - Auth Headers
    
    func authHeaders() -> [String: String]? {
        guard let token = accessToken else { return nil }
        return ["Authorization": "Bearer \(token)"]
    }
    
    // MARK: - Signup
    
    func signup(email: String, username: String, password: String) async throws -> TokenPair {
        let request = SignupRequest(email: email, username: username, password: password)
        let response: TokenPair = try await apiService.request(
            endpoint: "/auth/signup",
            method: "POST",
            body: request
        )
        
        // Store tokens
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        
        return response
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async throws -> TokenPair {
        let request = LoginRequest(email: email, password: password)
        let response: TokenPair = try await apiService.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request
        )
        
        // Store tokens
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        
        return response
    }
    
    // MARK: - Refresh Token
    
    func refreshAccessToken() async throws -> TokenPair {
        guard let refresh = refreshToken else {
            throw APIError(detail: "No refresh token available")
        }
        
        let request = RefreshRequest(refreshToken: refresh)
        let response: TokenPair = try await apiService.request(
            endpoint: "/auth/refresh",
            method: "POST",
            body: request
        )
        
        // Update tokens
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        
        return response
    }
    
    // MARK: - Get Current User
    
    func getCurrentUser() async throws -> User {
        guard let headers = authHeaders() else {
            throw APIError(detail: "Not authenticated")
        }
        
        return try await apiService.request(
            endpoint: "/auth/me",
            method: "GET",
            headers: headers
        )
    }
    
    // MARK: - Logout
    
    func logout() {
        accessToken = nil
        refreshToken = nil
    }
}

