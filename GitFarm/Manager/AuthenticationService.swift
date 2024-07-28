//
//  AuthenticationService.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

import SwiftUI
import Combine

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let loggedInKey = "isLoggedIn"
    private let userKey = "loggedInUser"
    
    private let clientId = "Ov23liIXUIOpefR5c1ao"
    private let clientSecret = "d4ac8d385ac88c928d3f4a3ff9dec101572bdcd8"
    
    func checkLoginStatus() -> (isLoggedIn: Bool, user: User?) {
        let isLoggedIn = userDefaults.bool(forKey: loggedInKey)
        let user = isLoggedIn ? getLoggedInUser() : nil
        return (isLoggedIn, user)
    }
    
    func saveLoginState(with user: User) {
        userDefaults.set(true, forKey: loggedInKey)
        if let encodedUser = try? JSONEncoder().encode(user) {
            userDefaults.setValue(encodedUser, forKey: userKey)
        }
    }
    
    func getLoggedInUser() -> User? {
        guard let userData = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: userData) else { return nil }
        return user
    }
    
    func logout() {
        userDefaults.removeObject(forKey: loggedInKey)
        userDefaults.removeObject(forKey: userKey)
    }
    
    func requestCodeToGitHub() {
        let scope = "repo,user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=\(scope)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func requestAccessTokenToGithub(with code: String) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let parameters = ["client_id": clientId,
                          "client_secret": clientSecret,
                          "code": code]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AccessTokenResponse.self, decoder: JSONDecoder())
            .map { $0.accessToken }
            .eraseToAnyPublisher()
    }
    
    func getUser(with accessToken: String) -> AnyPublisher<User, Error> {
        guard let url = URL(string: "https://api.github.com/user") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601 // Standard!

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: User.self, decoder: decoder)
//            .handleEvents(receiveOutput: { [weak self] user in
//                self?.userSubject.send(user)
//            })
            .eraseToAnyPublisher()
    }
}
