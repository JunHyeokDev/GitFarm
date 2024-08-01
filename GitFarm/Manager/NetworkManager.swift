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
    case invalidReponse = "Invalid response from the server. Please try again."
    case invalidData  = "The data received from the server was invaild. Please try again."
    case invalidURL = "URL is invalid"
    case jsonConvertError = "Something went wrong during converting JSON"
    case failedToFavorite = "Failed to list a user to your favorites! Please try again."
    case alreadyInFavorites = "You've already favorited this user!!"
    case defaultError = "just... Error!"
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.github.com/graphql"
    private let token = Config.GHtoken
    private let _baseURL = "https://api.github.com"
    private let _followersPerPage = "100"
    
    func fetchCommitHistories(with username: String) -> AnyPublisher<[CommitHistory], NetworkError> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        guard !username.isEmpty else {
            return Fail(error: .invalidUsername).eraseToAnyPublisher() // 또는 사용자 지정 오류
        }
        
        
        let query = """
            query($username: String!) {
              user(login: $username) {
                contributionsCollection {
                  contributionCalendar {
                    totalContributions
                    weeks {
                      contributionDays {
                        contributionCount
                        date
                      }
                    }
                  }
                }
              }
            }
            """
        
        let variables = ["username": username]
        let body = ["query": query, "variables": variables] as [String : Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { data, response in
                print("응답하라 : \(response)")
                print("데이터 : \(String(data: data, encoding: .utf8) ?? "변환실패..;")")
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.invalidData
                }
                return data
            }
            .handleEvents(receiveOutput: { data in
                print("trymap 후 데이터 : \(String(data: data, encoding: .utf8) ?? "변환실패..;")")
            })
            .decode(type: GitHubContributionsResponse.self, decoder: JSONDecoder())
            .tryMap { response -> [CommitHistory] in
                print("Decoded response: \(response)") // 1. 응답 출력
                // 2. 디버깅 포인트 설정 (Xcode에서 이 줄 왼쪽 여백을 클릭)
                return response.convertToCommitHistories() // 3. 변환 후 반환
            }
        
            .handleEvents(receiveOutput: { contributions in
                print("Converted contributions: \(contributions)")
            })
            .mapError { error -> NetworkError in
                print("Caught error: \(error)")
                if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.defaultError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getUserInfo(with username: String) -> AnyPublisher<User, NetworkError> {
        let endpoint = _baseURL + "/users/\(username)"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601 // Standard!

        
        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.invalidReponse
                }
                return data
            }
            .decode(type: User.self, decoder: decoder) // User 디코딩
            .mapError { error in
                if error is DecodingError {
                    print(error)
                    print(error.localizedDescription)
                    return NetworkError.jsonConvertError
                } else {
                    return NetworkError.defaultError
                }
            }
            .receive(on: DispatchQueue.main) // 메인 스레드에서 결과 처리
            .eraseToAnyPublisher()
    }
    
    func getFollowers(for username: String, page: Int) -> AnyPublisher<[Follower],NetworkError> {
        let endpoint = _baseURL + "/users/\(username)/followers?per_page=\(_followersPerPage)&page=\(page)"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.invalidReponse
                }
                return data
            }
        
            .decode(type: [Follower].self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    print(error.localizedDescription)
                    return NetworkError.jsonConvertError
                } else {
                    return NetworkError.defaultError
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
//    func getFollowers(for username:String, page: Int, completed: @escaping(Result<[User],NetworkError>) -> Void ) {
//        let endpoint = _baseURL + "/users/\(username)/followers?per_page=\(_followersPerPage)&page=\(page)"
//        
//        guard let url = URL(string: endpoint) else {
//            completed(.failure(.invalidURL))
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let _ = error { completed(.failure(.unableToComplete)) }
//            
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                completed(.failure(.invalidReponse))
//                return
//            }
//            
//            guard let data = data else {
//                completed(.failure(.invalidData))
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let followers = try decoder.decode([User].self, from: data) // [Follower].self ??
//                completed(.success(followers)) // Good to go
//            } catch {
//                //completed(nil,error.localizedDescription) // It's good for debug, but not for user!
//                completed(.failure(.invalidData))
//            }
//        }
//        task.resume() // This is what really makes the netwroking job
//    }
    
}

extension NetworkManager {
    struct reqestUrl {
        static let scheme = "https"
        static let host = "github.com"
        static let path = "/users"
    }
}
