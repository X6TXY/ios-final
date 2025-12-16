import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case decodingError
    case serverError(Int)
    case serverMessage(Int, String)
    case noData
    case unauthorized
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL."
        case .decodingError:
            return "Failed to decode response."
        case .serverError(let code):
            return "Server responded with status \(code)."
        case .serverMessage(let code, let message):
            return "\(message) (code \(code))"
        case .noData:
            return "Empty response from server."
        case .unauthorized:
            return "No access token. Please sign in again."
        }
    }
}

private struct APIErrorResponse: Decodable {
    let detail: String?
}

final class APIClient {
    static let shared = APIClient()

    // Change this for real deployment (e.g. to your server IP / domain)
    // Use 127.0.0.1 for simulator; for real device set your Mac LAN IP.
    private let baseURLString = "http://127.0.0.1:8000"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        session = URLSession(configuration: config)
    }

    // MARK: - Token storage

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "access_token") }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "refresh_token") }
    }

    // MARK: - Public API – Auth

    func signIn(
        _ requestBody: SignInRequest,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        requestTokenPair(
            path: "/auth/login",
            body: requestBody
        ) { [weak self] result in
            switch result {
            case .success:
                self?.fetchCurrentUser(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func signUp(
        _ requestBody: SignUpRequest,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        requestTokenPair(
            path: "/auth/signup",
            body: requestBody
        ) { [weak self] result in
            switch result {
            case .success:
                self?.fetchCurrentUser(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func refreshAccessToken(
        completion: @escaping (Result<TokenPair, Error>) -> Void
    ) {
        guard let token = refreshToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        let body = RefreshRequest(refresh_token: token)
        requestTokenPair(
            path: "/auth/refresh",
            body: body,
            completion: completion
        )
    }

    func getCurrentUser(
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        fetchCurrentUser(completion: completion)
    }

    // MARK: - Public API – Profiles

    func getProfile(
        userId: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        authorizedGET(
            path: "/profiles/\(userId)",
            completion: completion
        )
    }

    func updateProfile(
        userId: String,
        body: ProfileUpdateRequest,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/profiles/\(userId)",
            method: "PUT",
            body: body,
            completion: completion
        )
    }

    // MARK: - Public API – Movies

    func getMovies(
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        request(
            path: "/movies/",
            method: "GET",
            completion: completion
        )
    }

    func getMovie(
        id: String,
        completion: @escaping (Result<Movie, Error>) -> Void
    ) {
        request(
            path: "/movies/\(id)",
            method: "GET",
            completion: completion
        )
    }

    func createMovie(
        body: MovieCreateRequest,
        completion: @escaping (Result<Movie, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/movies/",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func updateMovie(
        id: String,
        body: MovieUpdateRequest,
        completion: @escaping (Result<Movie, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/movies/\(id)",
            method: "PUT",
            body: body,
            completion: completion
        )
    }

    func deleteMovie(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authorizedRequestVoid(
            path: "/movies/\(id)",
            method: "DELETE",
            completion: completion
        )
    }

    func getRecommendations(
        limit: Int = 20,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        authorizedGET(
            path: "/movies/recommendations?limit=\(limit)",
            completion: completion
        )
    }

    func getMyActivity(
        completion: @escaping (Result<[MovieActivityItem], Error>) -> Void
    ) {
        authorizedGET(
            path: "/movies/activity",
            completion: completion
        )
    }

    func getCast(
        movieId: String,
        completion: @escaping (Result<[CastMemberDTO], Error>) -> Void
    ) {
        request(
            path: "/movies/\(movieId)/cast",
            method: "GET",
            completion: completion
        )
    }

    func setFavorite(
        movieId: String,
        isFavorite: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let method = isFavorite ? "POST" : "DELETE"
        authorizedRequestVoid(
            path: "/movies/\(movieId)/favorites",
            method: method,
            completion: completion
        )
    }

    func setDislike(
        movieId: String,
        isDisliked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let method = isDisliked ? "POST" : "DELETE"
        authorizedRequestVoid(
            path: "/movies/\(movieId)/dislikes",
            method: method,
            completion: completion
        )
    }

    func updateStatus(
        movieId: String,
        status: MovieStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let body = MovieStatusUpdateRequest(status: status)
        authorizedRequestVoid(
            path: "/movies/\(movieId)/status",
            method: "PUT",
            body: body,
            completion: completion
        )
    }

    func swipe(
        movieId: String,
        userId: String,
        direction: SwipeDirection,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let body = SwipeRequest(user_id: userId, direction: direction)
        authorizedRequestVoid(
            path: "/movies/\(movieId)/swipes",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    // MARK: - Public API – Friends

    func getFriends(
        completion: @escaping (Result<[FriendOut], Error>) -> Void
    ) {
        authorizedGET(
            path: "/friends/",
            completion: completion
        )
    }

    func getFriendRequests(
        completion: @escaping (Result<[FriendOut], Error>) -> Void
    ) {
        authorizedGET(
            path: "/friends/requests",
            completion: completion
        )
    }

    func createFriendRequest(
        body: FriendRequestCreateRequest,
        completion: @escaping (Result<FriendOut, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/friends/requests",
            method: "POST",
            body: body,
            completion: completion
        )
    }

    func acceptFriend(
        friendId: Int,
        completion: @escaping (Result<FriendOut, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/friends/\(friendId)/accept",
            method: "POST",
            completion: completion
        )
    }

    func blockFriend(
        friendId: Int,
        completion: @escaping (Result<FriendOut, Error>) -> Void
    ) {
        authorizedRequest(
            path: "/friends/\(friendId)/block",
            method: "POST",
            completion: completion
        )
    }

    func getFriendSuggestions(
        completion: @escaping (Result<[FriendSuggestion], Error>) -> Void
    ) {
        authorizedGET(
            path: "/friends/suggestions",
            completion: completion
        )
    }

    // MARK: - Private helpers

    private func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        authorizedGET(path: "/auth/me", completion: completion)
    }

    private func requestTokenPair<Body: Encodable>(
        path: String,
        body: Body,
        completion: @escaping (Result<TokenPair, Error>) -> Void
    ) {
        guard let url = URL(string: baseURLString + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.noData))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure(self?.mapHTTPError(status: httpResponse.statusCode, data: data) ?? APIError.serverError(httpResponse.statusCode)))
                return
            }

            do {
                let pair = try JSONDecoder().decode(TokenPair.self, from: data)
                self?.accessToken = pair.accessToken
                self?.refreshToken = pair.refreshToken
                completion(.success(pair))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }

    // Generic request helpers

    private struct EmptyBody: Encodable {}

    private func request<T: Decodable>(
        path: String,
        method: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURLString + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                let data = data
            else {
                completion(.failure(APIError.noData))
                return
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure(self.mapHTTPError(status: httpResponse.statusCode, data: data)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }

    private func authorizedGET<T: Decodable>(
        path: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        authorizedRequest(
            path: path,
            method: "GET",
            completion: completion
        )
    }

    private func authorizedRequest<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURLString + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                let data = data
            else {
                completion(.failure(APIError.noData))
                return
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure(self.mapHTTPError(status: httpResponse.statusCode, data: data)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }

    private func authorizedRequest<T: Decodable>(
        path: String,
        method: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        authorizedRequest(
            path: path,
            method: method,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    private func authorizedRequestVoid<Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURLString + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.noData))
                return
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                completion(.failure(self.mapHTTPError(status: httpResponse.statusCode, data: data)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    private func authorizedRequestVoid(
        path: String,
        method: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        authorizedRequestVoid(
            path: path,
            method: method,
            body: Optional<EmptyBody>.none,
            completion: completion
        )
    }

    // MARK: - Error mapping

    private func mapHTTPError(status: Int, data: Data?) -> APIError {
        if let data = data,
           let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
           let detail = apiError.detail,
           !detail.isEmpty {
            return .serverMessage(status, detail)
        }
        if status == 401 {
            handleUnauthorized()
            return .unauthorized
        }
        return .serverError(status)
    }

    // MARK: - Auth flow helper

    private func handleUnauthorized() {
        DispatchQueue.main.async {
            // mark as logged out
            UserDefaults.standard.set(false, forKey: "authorized")
            UserDefaults.standard.removeObject(forKey: "access_token")
            UserDefaults.standard.removeObject(forKey: "refresh_token")

            guard
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first
            else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authNav = storyboard.instantiateViewController(
                withIdentifier: "AuthNavigationController"
            )

            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = authNav
                },
                completion: nil
            )
        }
    }
}

