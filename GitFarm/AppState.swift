//
//  AppState.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentUser: User?
    
    static let shared = AppState()
    private init() {}
}
