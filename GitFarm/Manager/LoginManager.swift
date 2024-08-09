//
//  LoginManager.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


class LoginManager: ObservableObject {
    static let shared = LoginManager()
    private init() {}

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    private var cancellables: Set<AnyCancellable> = []

    private let userDefaults = UserDefaults.standard
    private let loggedInKey = "isLoggedIn"
    private let userKey = "loggedInUser"

    private let client_id = "Ov23liIXUIOpefR5c1ao"
    private let client_secret = "d4ac8d385ac88c928d3f4a3ff9dec101572bdcd8"

    func checkLoginStatus() {
        isLoggedIn = userDefaults.bool(forKey: loggedInKey)
        if isLoggedIn {
            currentUser = getLoggedInUser()
        }
    }
    
    func logout() {
        userDefaults.removeObject(forKey: loggedInKey)
        userDefaults.removeObject(forKey: userKey)
        isLoggedIn = false
        currentUser = nil
        
        // Widget 관련 데이터 삭제
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            userDefaults.removeObject(forKey: "commitTimeline")
            userDefaults.removeObject(forKey: "commitHistories")
            userDefaults.removeObject(forKey: "userInfoVM")
        }
        
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }

    let userSubject = PassthroughSubject<User, Never>()
    
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
    
    func login(with user: User) {
        saveLoginState(with: user)
        isLoggedIn = true
        currentUser = user
        NotificationCenter.default.post(name: .userLoggedIn, object: nil)
    }
    
    
    func requestCodeToGitHub() {
        let scope = "repo,user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(client_id)&scope=\(scope)"
        guard let url = URL(string: urlString) else { return }

        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    func requestAccessTokenToGithub(with code: String) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let parameters = ["client_id": client_id,
                          "client_secret": client_secret,
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
                print("Response: \(response)")
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                    print("Headers: \(httpResponse.allHeaderFields)")
                }
                print("Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                
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
            .handleEvents(receiveOutput: { [weak self] user in
                self?.userSubject.send(user)
            })
            .eraseToAnyPublisher()
    }
    
    func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let codeItem = components.queryItems?.first(where: { $0.name == "code" }),
              let code = codeItem.value else {
            return
        }

        requestAccessTokenToGithub(with: code)
            .flatMap { accessToken -> AnyPublisher<User, Error> in
                self.getUser(with: accessToken)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error: \(error.localizedDescription)")
                        print("Error : \(error)")
                        print("requestAccessTokenToGithub")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.saveLoginState(with: user)
                    self?.isLoggedIn = true
                    self?.currentUser = user
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - AccessTokenResponse
struct AccessTokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Notification
extension Notification.Name {
    static let userLoggedIn = Notification.Name("userLoggedIn")
    static let userLoggedOut = Notification.Name("userLoggedOut")
}
