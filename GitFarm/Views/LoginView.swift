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
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                // 로고 또는 일러스트레이션
                Image("LoginViewImage") // 적절한 이미지 에셋을 추가해야 합니다
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                
                Text("Welcome to GitFarm")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Grow your commits, harvest your progress!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // GitHub 로그인 버튼
                Button(action: {
                    loginManager.requestCodeToGitHub()
                }) {
                    HStack {
                        Image(systemName: "leaf.fill")
                        Text("Login with GitHub")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.top)
            }
            .padding()
        }
        .gradientBackground()
        .onAppear {
            isAnimating = true
        }
    }
}
