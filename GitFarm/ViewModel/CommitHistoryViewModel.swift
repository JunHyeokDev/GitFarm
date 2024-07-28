//
//  CommitHistoryViewModel.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Combine
import SwiftUI

class CommitHistoryViewModel: ObservableObject {
    // MARK: - Combine
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Properties
    @Published var commitHistories: [CommitHistory] = []
    @Published var user: User?
    @Published var login: String = "Default user ID"
    @Published var username: String = "Default user name"
    @Published var todayContributionCount: Int?
    @Published var isInitial: Bool = true
    @Published var isInvalidname: Bool = false
    @Published var totalContributionsInThisYear: Int = 0
    @Published var bio: String = "I'm a Git farmer! 🧑🏻‍🌾👩🏻‍🌾👨🏻‍🌾"
    @Published var name: String = "😱 No name 🤷🏼‍♂️"
    @Published var location: String = "Somewhere 👀"
    @Published var followers: String = "123"
    @Published var following: String = "321"
    
    init(with user: User) {
        self.user = user
        var username = UserDefaults.standard.string(forKey: "username") ?? ""
        if username == "" {
            username = user.login
        }
        fetchCommitHistories(with: user.login)
        
        LoginManager.shared.userSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
                self?.configureVM(with: self?.commitHistories ?? [])
            }
            .store(in: &cancellables)
    }
    
    func updateUser(_ newUser: User) {
        self.user = newUser
        var username = UserDefaults.standard.string(forKey: "username") ?? ""
        if username == "" {
            username = newUser.login
        }
        
        // 사용자 정보 업데이트
        self.login = newUser.login
        self.username = newUser.login
        self.name = newUser.name ?? "Anonymous"
        self.bio = newUser.bio ?? "I'm a Git farmer! 🧑🏻‍🌾👩🏻‍🌾👨🏻‍🌾"
        self.location = newUser.location ?? "S.Korea"
        
        let followerCount = newUser.followers
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        self.followers = numberFormatter.string(from: NSNumber(value: followerCount)) ?? ""
        
        let followingCount = newUser.following
        self.following = numberFormatter.string(from: NSNumber(value: followingCount)) ?? ""
        
        // UserDefaults에 새로운 사용자 정보 저장
        saveUserInfoVMToUserDefaults(with: newUser)
        
        // 새로운 사용자의 커밋 히스토리 가져오기
        fetchCommitHistories(with: newUser.login)
    }

    func reset() {
        user = nil
        commitHistories = []
        login = "Default user ID"
        username = "Default user name"
        todayContributionCount = nil
        isInitial = true
        isInvalidname = false
        totalContributionsInThisYear = 0
        bio = "I'm a Git farmer! 🧑🏻‍🌾👩🏻‍🌾👨🏻‍🌾"
        name = "😱 No name 🤷🏼‍♂️"
        location = "Somewhere 👀"
        followers = "123"
        following = "321"
    }

    
    func saveUserInfoVMToUserDefaults(with user : User) {
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")  {
            let encodedData = try? JSONEncoder().encode(user)
            userDefaults.set(encodedData, forKey: "userInfoVM")
        }
    }
    
    func saveCommitHistoriesToUserDefaults(with arr : [[CommitHistory]]) {
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            let encodedData = try? JSONEncoder().encode(arr)
            userDefaults.set(encodedData, forKey: "commitHistories")
        }
        else {
            print("ERROR during shared UserDefaults")
        }
    }

    func configureVM(with commitHistories: [CommitHistory]) {
        username = user?.login ?? "Anonymous"
        todayContributionCount = commitHistories.filter { Calendar.current.isDateInToday($0.date) }.first?.count

        isInitial = commitHistories.isEmpty

        totalContributionsInThisYear = commitHistories
            .filter { Calendar.current.component(.year, from: $0.date) == Calendar.current.component(.year, from: Date()) }
            .map { $0.count }
            .reduce(0, +)

        name = user?.name ?? "Anonymous"
        bio = user?.bio ?? "I'm a Git farmer! 🧑🏻‍🌾👩🏻‍🌾👨🏻‍🌾"
        location = user?.location ?? "S.Korea"

        let followerCount = user?.followers ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedFollowerCount = numberFormatter.string(from: NSNumber(value: followerCount)) ?? ""
        followers = formattedFollowerCount

        let followingCount = user?.following ?? 0
        let formattedFollowingCount = numberFormatter.string(from: NSNumber(value: followingCount)) ?? ""
        following = formattedFollowingCount
        saveUserInfoVMToUserDefaults(with: user!)
        //startYear = String(user?.createdAt.year ?? Date().year)
    }

    func commitHistorySet(columnsCount: Int) -> [[CommitHistory]] {
        guard let lastDate = commitHistories.last?.date else {
            return []
        }

        let rows = 7
        let columns = 17

        let cellCount = rows * columns - (rows - Calendar.current.component(.weekday, from: lastDate)) // Provide default value for lastDate

        let chunkedHistories = commitHistories.suffix(cellCount).slice(into: rows)
        var result: [[CommitHistory]] = []

        for week in chunkedHistories {
            var filledWeek: [CommitHistory] = []
            for history in week {
                filledWeek.append(history)
            }
            result.append(filledWeek)
        }
        self.saveCommitHistoriesToUserDefaults(with: result)
        return result
    }
    
    func fetchCommitHistories(with username: String) {
        UserDefaults.standard.set(username, forKey: "username")
        NetworkManager.shared.fetchCommitHistories(with: username)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("fetchCommitHistories Successfully finished")
                    case .failure:
                        print("fetchCommitHistories fail..!")
                    }
                },
                receiveValue: { [weak self] commitHistories in
                    // 최근 140일의 데이터만 가져옵니다.
                    self?.commitHistories = commitHistories
                    self?.configureVM(with: commitHistories)
                    // 디버깅을 위한 출력
                    print("Total commit histories: \(commitHistories.count)")
                    for (index, commit) in commitHistories.enumerated() {
                        print("Index: \(index), Date: \(commit.date), Count: \(commit.count)")
                    }
                }
            )
            .store(in: &cancellables)
    }
}
