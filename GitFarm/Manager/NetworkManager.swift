//
//  NetworkManager.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Combine
import Foundation

enum NetworkError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again"
    case unableToComplete = "Unable to complete your request. Please Check your internet connection"
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData  = "The data received from the server was invaild. Please try again."
    case invalidURL = "URL is invalid"
    case jsonConvertError = "Something went wrong during converting JSON"
    case failedToFavorite = "Failed to list a user to your favorites! Please try again."
    case alreadyInFavorites = "You've already favorited this user!!"
    case defaultError = "just... Error!"
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let cache = NSCache<NSString, AnyObject>()
    
    private init() {}
    
    private let baseURL = "https://api.github.com/graphql"
    private let token = Config.GHtoken
    private let _baseURL = "https://api.github.com"
    private let _followersPerPage = "100"
    
    func fetchCommitHistories(with username: String) async throws -> [CommitHistory] {
         let query = Config.query
         let variables = ["username": username]
         let body = ["query": query, "variables": variables] as [String : Any]
         var request = URLRequest(url: URL(string: baseURL)!)
         request.httpMethod = "POST"
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.httpBody = try? JSONSerialization.data(withJSONObject: body)
         
         let (data, response) = try await URLSession.shared.data(for: request)
         guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
             throw NetworkError.invalidData
         }
         
         let gitHubResponse = try JSONDecoder().decode(GitHubContributionsResponse.self, from: data)
         return gitHubResponse.convertToCommitHistories()
     }

    func getUserInfo(with username: String) async throws -> User {
        let endpoint = _baseURL + "/users/\(username)"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(Config.GHtoken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(User.self, from: data)
    }
    
    func getFollowers(for username: String, page: Int) -> AnyPublisher<[Follower],Error> {
        print("GetFollowers Start")
        let endpoint = _baseURL + "/users/\(username)/followers?per_page=\(_followersPerPage)&page=\(page)"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.GHtoken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .decode(type: [Follower].self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    print(error.localizedDescription)
                    return NetworkError.jsonConvertError
                } else {
                    print(error)
                    print("getFollowers fail")
                    return NetworkError.defaultError
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

extension NetworkManager {
    struct reqestUrl {
        static let scheme = "https"
        static let host = "github.com"
        static let path = "/users"
    }
}

// MARK: - getRepositories & getCommits
extension NetworkManager {
    
    func getRepositories(for username: String) async throws -> [Repository] {
        let endpoint = "https://api.github.com/users/\(username)/repos"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(Config.GHtoken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode([Repository].self, from: data)
    }
    
    func getCommits(for repo: String, owner: String) async throws -> [Commit] {
        let endpoint = "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=100"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(Config.GHtoken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode([Commit].self, from: data)
        case 409:
            print("Repository \(repo) is empty or inaccessible")
            return []
        default:
            throw NetworkError.invalidResponse
        }
    }
}
