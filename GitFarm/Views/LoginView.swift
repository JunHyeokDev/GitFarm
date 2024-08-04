//
//  LoginView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//
 
import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var loginManager: LoginManager
    
    var body: some View {
        VStack {
            Text("Welcome to GitFarm")
                .foregroundStyle(Color.accent)
                .font(.largeTitle)
                .padding()
            
            Button("Login with GitHub") {
                loginManager.requestCodeToGitHub()
            }
            .foregroundStyle(Color.accent)
            .padding()
        }
    }
}
