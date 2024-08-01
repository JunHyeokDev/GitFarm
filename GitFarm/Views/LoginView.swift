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
                .font(.largeTitle)
                .padding()
            
            Button("Login with GitHub") {
                loginManager.requestCodeToGitHub()
            }
            .padding()
        }
    }
}
