//
//  NetworkManager.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Combine
import Foundation

enum NetworkError: Error {
    case error(String)
    case invalidURL
    case htmlParsingError
    case jsonDecodingError
    case defaultError
    
    var message: String? {
        switch self {
        case let .error(msg):
            return msg
        case .invalidURL:
            return "### Error: invalid URL-getContributions @GitHubNetwork.swift ###"
        case .htmlParsingError:
            return "### Error: HTML parsing @GitHubNetwork.swift ###"
        case .jsonDecodingError:
            return "### Error: JSON Decoding @GitHubNetwork.swift ###"
        case .defaultError:
            return "잠시 후에 다시 시도해주세요."
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let baseURL = "https://api.github.com/graphql"
    private let token = Config.GHtoken
    private let _baseURL = "https://api.github.com"

    
    func fetchCommitHistories(with username: String) -> AnyPublisher<[CommitHistory], NetworkError> {
            guard let url = URL(string: baseURL) else {
                return Fail(error: .invalidURL).eraseToAnyPublisher()
            }
            guard !username.isEmpty else {
                return Fail(error: .defaultError).eraseToAnyPublisher() // 또는 사용자 지정 오류
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
                    throw NetworkError.defaultError
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
                }
                return .error("Error: \(error)")
            }
            .eraseToAnyPublisher()
        }
    
    func getUserInfo(with username: String) -> AnyPublisher<User, NetworkError> {
        let endpoint = _baseURL + "/users/\(username)"

        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.defaultError).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.defaultError
                }
                return data
            }
            .decode(type: User.self, decoder: JSONDecoder()) // User 디코딩
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.defaultError
                } else {
                    return NetworkError.defaultError
                }
            }
            .receive(on: DispatchQueue.main) // 메인 스레드에서 결과 처리
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
