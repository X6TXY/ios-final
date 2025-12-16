//
//  Models.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import Foundation

// MARK: - Auth

struct SignInRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let username: String
}

struct RefreshRequest: Encodable {
    let refresh_token: String
}

struct TokenPair: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

// MARK: - Movies

struct Movie: Decodable {
    /// Backend id (may be missing for local dummy movies)
    let id: String?
    let title: String
    let overview: String?
    let release_date: String?
    let rating: Float?
    let popularity: Float?
    let poster_url: String?
    let backdrop_url: String?
    let genres: [String]?
    let keywords: [String]?
}

extension Movie {
    /// Resolve TMDB-style path or full URL to URL
    var posterURL: URL? {
        resolveImageURL(from: poster_url)
    }

    var backdropURL: URL? {
        resolveImageURL(from: backdrop_url)
    }

    private func resolveImageURL(from raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        if raw.hasPrefix("http") { return URL(string: raw) }
        // Default TMDB path
        return URL(string: "https://image.tmdb.org/t/p/w500\(raw)")
    }
}

struct MovieCreateRequest: Encodable {
    let title: String
    let overview: String?
    let release_date: String?
    let rating: Float?
    let popularity: Float?
    let poster_url: String?
    let backdrop_url: String?
    let genres: [String]?
    let keywords: [String]?
}

/// Partial update for movie
struct MovieUpdateRequest: Encodable {
    let title: String?
    let overview: String?
    let release_date: String?
    let rating: Float?
    let popularity: Float?
    let poster_url: String?
    let backdrop_url: String?
    let genres: [String]?
    let keywords: [String]?
}

enum MovieStatus: String, Encodable {
    case watching
    case wantToWatch = "want_to_watch"
    case completed
    case dropped
}

struct MovieStatusUpdateRequest: Encodable {
    let status: MovieStatus
}

enum SwipeDirection: String, Encodable {
    case like
    case dislike
}

struct SwipeRequest: Encodable {
    let user_id: String
    let direction: SwipeDirection
}

extension Movie {
    static let dummy1 = Movie(
        id: "1",
        title: "Example Movie",
        overview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ut lorem ut efficitur. Morbi suscipit metus eu lorem vehicula, eu convallis dui lacinia. Fusce volutpat scelerisque nisi. Nullam risus mi, posuere id placerat ac, blandit ut dolor. In eleifend id purus tristique tincidunt. Duis ultrices rhoncus nisl in feugiat. Phasellus odio diam, tristique a venenatis ut, scelerisque facilisis ex. Ut sit amet sagittis erat. Vivamus ullamcorper arcu a volutpat tempor. Mauris pretium et nunc a sollicitudin. Sed varius porta quam, eu scelerisque justo ornare ut. Aliquam scelerisque arcu a mi mattis, sit amet commodo ligula vehicula.",
        release_date: "2025-12-14",
        rating: 8.5,
        popularity: 123.4,
        poster_url: "https://upload.wikimedia.org/wikipedia/en/1/1e/Everything_Everywhere_All_at_Once.jpg",
        backdrop_url: "https://i0.wp.com/arbiteronline.com/wp-content/uploads/2022/04/EEAAO-Photo-1.png",
        genres: ["Action", "Adventure"],
        keywords: ["hero", "journey", "battle"]
    )
    static let dummy2 = Movie(
        id: "2",
        title: "Example Movie",
        overview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ut lorem ut efficitur. Morbi suscipit metus eu lorem vehicula, eu convallis dui lacinia. Fusce volutpat scelerisque nisi. Nullam risus mi, posuere id placerat ac, blandit ut dolor. In eleifend id purus tristique tincidunt. Duis ultrices rhoncus nisl in feugiat. Phasellus odio diam, tristique a venenatis ut, scelerisque facilisis ex. Ut sit amet sagittis erat. Vivamus ullamcorper arcu a volutpat tempor. Mauris pretium et nunc a sollicitudin. Sed varius porta quam, eu scelerisque justo ornare ut. Aliquam scelerisque arcu a mi mattis, sit amet commodo ligula vehicula.",
        release_date: "2025-12-14",
        rating: 8.5,
        popularity: 123.4,
        poster_url: "https://m.media-amazon.com/images/M/MV5BOWNmMzAzZmQtNDQ1NC00Nzk5LTkyMmUtNGI2N2NkOWM4MzEyXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
        backdrop_url: "https://i0.wp.com/scalawagmagazine.org/wp-content/uploads/2023/03/EEAAOheader.png",
        genres: ["Action", "Adventure"],
        keywords: ["hero", "journey", "battle"]
    )
    
    static let dummy3 = Movie(
        id: "3",
        title: "Black Widow",
        overview: "Natasha Romanoff confronts the darker parts of her ledger when a dangerous conspiracy with ties to her past arises.",
        release_date: "2025-12-14",
        rating: 8.5,
        popularity: 123.4,
        poster_url: "https://m.media-amazon.com/images/I/81Jgy1tfvcL._AC_UF1000,1000_QL80_.jpg",
        backdrop_url: "https://media.vanityfair.com/photos/5a57a029b16ba04a7fe0172b/master/pass/Black-Widow.jpg",
        genres: ["Action", "Adventure"],
        keywords: ["hero", "journey", "battle"]
    )
}

// MARK: - User / Profile

struct User: Decodable {
    let id: String
    let email: String
    let username: String
}

extension User {
    static let dummy1 = User(id: "1", email: "dummy@example.com", username: "dummy")
}



struct Profile: Decodable {
    let avatar_url: String?
    let id: String
    let user_id: String
}

extension Profile {
    static let dummy1 = Profile(
        avatar_url: "https://i.pinimg.com/236x/68/31/12/68311248ba2f6e0ba94ff6da62eac9f6.jpg",
        id: "1",
        user_id: User.dummy1.id
    )
}

struct ProfileUpdateRequest: Encodable {
    let avatar_url: String?
    let bio: String?
    let location: String?
    let birthdate: String?
}

// MARK: - Friends

enum FriendStatus: String, Decodable {
    case pending
    case accepted
    case blocked
}

struct FriendOut: Decodable {
    let id: String
    let requester_id: String
    let addressee_id: String
    let status: FriendStatus
    let created_at: String?
    let updated_at: String?
}

struct FriendRequestCreateRequest: Encodable {
    let requester_id: String
    let addressee_id: String
}

struct FriendSuggestion: Decodable {
    let user_id: String
    let username: String
    let email: String
    let similarity_score: Double?
    let top_genres: [String]?
}

// MARK: - Activity feed

struct MovieActivityItem: Decodable {
    let movie: Movie
    let direction: String   // "like" | "dislike"
    let created_at: String
}

struct CastMemberDTO: Decodable {
    let name: String
    let character: String?
    let profile_url: String?

    var profileURL: URL? {
        guard let profile_url, !profile_url.isEmpty else { return nil }
        return URL(string: profile_url)
    }
}

enum Activity {
    case like
    case dislike
    case watchlist
}

struct FriendsActivity {
    let movie: Movie
    let user: User
    let user_profile: Profile
    let activity : Activity
}


extension FriendsActivity {



    static let dummies: [FriendsActivity] = [
        FriendsActivity(
            movie: .dummy1,
            user: .dummy1,
            user_profile: .dummy1,
            activity: .like
        ),
        FriendsActivity(
            movie: .dummy2,
            user: .dummy1,
            user_profile: .dummy1,
            activity: .dislike
        ),
        FriendsActivity(
            movie: .dummy1,
            user: .dummy1,
            user_profile: .dummy1,
            activity: .watchlist
        )
    ]
}
