//
//  MovieModels.swift
//  ios
//
//  Movie Models for API Responses
//

import Foundation

struct Movie: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let releaseDate: String?
    let duration: Int? // in minutes
    let genres: [String]
    let posterUrl: String?
    let backdropUrl: String?
    let rating: Double?
    let matchPercentage: Int?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case releaseDate = "release_date"
        case duration
        case genres
        case posterUrl = "poster_url"
        case backdropUrl = "backdrop_url"
        case rating
        case matchPercentage = "match_percentage"
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        id = UUID(uuidString: idString) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        genres = try container.decodeIfPresent([String].self, forKey: .genres) ?? []
        posterUrl = try container.decodeIfPresent(String.self, forKey: .posterUrl)
        backdropUrl = try container.decodeIfPresent(String.self, forKey: .backdropUrl)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        matchPercentage = try container.decodeIfPresent(Int.self, forKey: .matchPercentage)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
}

struct MovieRecommendation: Codable {
    let movie: Movie
    let reason: String?
}

struct MoviesResponse: Codable {
    let movies: [Movie]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct MovieSection: Codable {
    let title: String
    let movies: [Movie]
}

struct FeaturedMovie: Codable {
    let movie: Movie
    let featured: Bool
}

