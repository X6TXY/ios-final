//
//  APIService.swift
//  ios
//
//  Base API Service
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration)
    }
    
    // MARK: - Request Building
    
    private func buildURL(endpoint: String) -> URL? {
        return URL(string: "\(baseURL)\(endpoint)")
    }
    
    private func buildRequest(url: URL, method: String, headers: [String: String]? = nil, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body
        return request
    }
    
    // MARK: - Generic Request
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint) else {
            throw APIError(detail: "Invalid URL")
        }
        
        var requestBody: Data?
        if let body = body {
            let encoder = JSONEncoder()
            // RefreshRequest uses custom CodingKeys, so we encode it separately
            if let refreshRequest = body as? RefreshRequest {
                requestBody = try JSONEncoder().encode(refreshRequest)
            } else {
                // Use snake_case encoding for other requests
                encoder.keyEncodingStrategy = .convertToSnakeCase
                requestBody = try encoder.encode(body)
            }
        }
        
        let request = buildRequest(url: url, method: method, headers: headers, body: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(detail: "Invalid response")
        }
        
        // Handle error status codes
        if httpResponse.statusCode >= 400 {
            // Try to decode error message
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Error response: \(responseString)")
            }
            throw APIError(detail: "HTTP \(httpResponse.statusCode)")
        }
        
        // Handle empty responses (204 No Content)
        if httpResponse.statusCode == 204 {
            // Return empty data for void responses
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
        }
        
        // Log response for debugging
        if let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty {
            print("Response data: \(responseString)")
        } else {
            print("Empty or invalid response data")
        }
        
        // Check if response is empty
        guard !data.isEmpty else {
            throw APIError(detail: "Empty response from server")
        }
        
        let decoder = JSONDecoder()
        // Don't use automatic snake_case conversion - types with CodingKeys handle it themselves
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            // Better error logging
            print("Decoding error details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found. Path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type). Path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("Value not found for type \(type). Path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted. Path: \(context.codingPath), Description: \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response was: \(responseString)")
            }
            throw APIError(detail: "Failed to decode response: \(decodingError.localizedDescription)")
        } catch {
            print("Decoding error: \(error)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response was: \(responseString)")
            }
            throw APIError(detail: "Failed to decode response: \(error.localizedDescription)")
        }
    }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {
    init() {}
}

