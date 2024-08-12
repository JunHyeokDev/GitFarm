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
    @Published var todayContributionCount = 0
    @Published var totalContributionsInThisYear = 0
    
    init(with user: User) async {
        self.user = user
        var username = UserDefaults.standard.string(forKey: "username") ?? ""
        if username == "" {
            username = user.login
        }
        await fetchCommitHistories(with: user.login)
        await updateUser(user)
    }
    
    func updateUser(_ user: User) async {
        self.user = user
        var username = UserDefaults.standard.string(forKey: "username") ?? ""
        if username.isEmpty {
            username = user.login
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // UserDefaults에 새로운 사용자 정보 저장
        saveUserInfoVMToUserDefaults(with: self.user ?? user)
        
        // 새로운 사용자의 커밋 히스토리 가져오기
        await fetchCommitHistories(with: user.login)
    }

    func saveUserInfoVMToUserDefaults(with user : User) {
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")  {
            let encodedData = try? JSONEncoder().encode(user)
            userDefaults.set(encodedData, forKey: "userInfoVM")
        }
    }
    
    func saveCommitHistoriesToUserDefaults(with arr : [CommitHistory]) {
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            let encodedData = try? JSONEncoder().encode(arr)
            userDefaults.set(encodedData, forKey: "commitHistories")
        }
        else {
            print("ERROR during shared UserDefaults")
        }
    }

    func configureVM(with commitHistories: [CommitHistory]) {
        todayContributionCount = commitHistories.filter { Calendar.current.isDateInToday($0.date) }.first?.count ?? 0
        totalContributionsInThisYear = commitHistories
            .filter { Calendar.current.component(.year, from: $0.date) == Calendar.current.component(.year, from: Date()) }
            .map { $0.count }
            .reduce(0, +)
        
        let followerCount = user?.followers ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedFollowerCount = numberFormatter.string(from: NSNumber(value: followerCount)) ?? ""
        self.user?.followers = Int(formattedFollowerCount) ?? 0

        let followingCount = user?.following ?? 0
        let formattedFollowingCount = numberFormatter.string(from: NSNumber(value: followingCount)) ?? ""
        self.user?.following = Int(formattedFollowingCount) ?? 0
        saveUserInfoVMToUserDefaults(with: user!)
    }

    static func commitHistorySet(with commitHistories : [CommitHistory], columnsCount: Int) -> [[CommitHistory]] {
        guard let lastDate = commitHistories.last?.date else {
            return []
        }

        let rows = 7
        let cellCount = rows * columnsCount - (rows - Calendar.current.component(.weekday, from: lastDate)) // Provide default value for lastDate

        let dividedCommitHistories = commitHistories.suffix(cellCount).slice(into: rows)
        var result: [[CommitHistory]] = []

        for week in dividedCommitHistories {
            var filledWeek: [CommitHistory] = []
            for history in week {
                filledWeek.append(history)
            }
            result.append(filledWeek)
        }
        return result
    }
    
    func fetchCommitHistories(with username: String) async {
        do {
            let commitHistories = try await NetworkManager.shared.fetchCommitHistories(with: username)
            DispatchQueue.main.async {
                self.commitHistories = commitHistories
                self.configureVM(with: commitHistories)
                self.saveCommitHistoriesToUserDefaults(with: commitHistories)
            }
        } catch {
            print("Error fetching commit histories: \(error)")
        }
    }
}
