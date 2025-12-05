//
//  MovieService.swift
//  ios
//
//  Movie Service for API Calls
//

import Foundation

extension APIService {
    
    /// Get movie recommendations for the current user
    func getRecommendations(limit: Int = 20, page: Int = 1) async throws -> [Movie] {
        let endpoint = "/movies/recommendations?limit=\(limit)&page=\(page)"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get trending movies
    func getTrending(limit: Int = 20) async throws -> [Movie] {
        let endpoint = "/movies/trending?limit=\(limit)"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get featured movies for hero section
    func getFeatured() async throws -> [Movie] {
        let endpoint = "/movies/featured"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get movies by genre
    func getMoviesByGenre(_ genre: String, limit: Int = 20) async throws -> [Movie] {
        let encodedGenre = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? genre
        let endpoint = "/movies?genre=\(encodedGenre)&limit=\(limit)"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get new releases
    func getNewReleases(limit: Int = 20) async throws -> [Movie] {
        let endpoint = "/movies?sort=release_date&order=desc&limit=\(limit)"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get continue watching movies
    func getContinueWatching() async throws -> [Movie] {
        let endpoint = "/movies/continue-watching"
        let response: MoviesResponse = try await request(endpoint: endpoint, method: "GET")
        return response.movies
    }
    
    /// Get movie by ID
    func getMovie(id: UUID) async throws -> Movie {
        let endpoint = "/movies/\(id.uuidString)"
        return try await request(endpoint: endpoint, method: "GET")
    }
}

