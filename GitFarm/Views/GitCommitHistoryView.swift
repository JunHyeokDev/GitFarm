//
//  GitCommitHistoryView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

//import SwiftUI
//
//// MARK: - GitCommitHistoryView
//struct GitCommitHistoryView: View {
//    
//    var commitHistories : [CommitHistory]?
//    var user : User?
//    
//    let columns = 17
//    let rows = 7
//    
//    let cloudImages = ["cloud1", "cloud2", "cloud3", "cloud4"]
//
//    var body: some View {
//        let commitHistorySet = CommitHistoryViewModel.commitHistorySet(with: commitHistories ?? [], columnsCount: columns)
//        
//        // 태양 중심 좌표 (x, y)
//        let sunCenterX: CGFloat = 25 / 2 // 태양 이미지 너비의 절반
//        // 태양 주변 안전 영역 반지름
//        let safeRadius: CGFloat = 30
//        
//        GeometryReader { geometry in
//            VStack(spacing:2) {
//                ZStack {
//                    Image("sun")
//                        .resizable()
//                        .frame(width: 25, height: 25)
//                        .offset(y:-15)
//                        .zIndex(1)
//                    
//                    // 왼쪽에 10개 구름 배치
//                    ForEach(0..<13, id: \.self) { index in
//                        Image(cloudImages.randomElement()!)
//                            .resizable()
//                            .frame(width: 20, height: CGFloat.random(in: 10...20))
//                            .offset(x: CGFloat.generateRandomXOffset(
//                                range: -414/2...0, // 왼쪽 절반 범위
//                                sunCenterX: sunCenterX,
//                                safeRadius: safeRadius
//                            ), y: CGFloat.random(in: -20...5))
//                    }
//                    
//                    // 오른쪽에 10개 구름 배치
//                    ForEach(0..<13, id: \.self) { index in
//                        Image(cloudImages.randomElement()!)
//                            .resizable()
//                            .frame(width: 20, height: CGFloat.random(in: 10...20))
//                            .offset(x: CGFloat.generateRandomXOffset(
//                                range: 0...414/2, // 오른쪽 절반 범위
//                                sunCenterX: sunCenterX,
//                                safeRadius: safeRadius
//                            ), y: CGFloat.random(in: -20...5))
//                    }
//                }
//                .frame(height: geometry.size.height * 0.15)
//                
//                VStack(alignment: .center, spacing: 7) {
//                    GitCommitView(columns: 17, rows: 7, size: geometry.size) { row, column in
//                        if let commitHistory = commitHistorySet.element(at: row)?.element(at: column) {
//                            GitCommitCellView(commitHistory: commitHistory)
//                        } else {
//                            Text(" ") // EmptyView
//                                .frame(width: 14, height: 14)
//                        }
//                    }
//                
//                    FenceView()
//                        .padding(.vertical,5)
//                    
//                    UserInfoView(user: user ?? User.defaultUser)
//                        .padding(.horizontal, 5) // 좌우 패딩 5 추가
//                        .padding(.vertical,5)
//                }
//                .frame(maxWidth: 414)
//                .frame(maxHeight: 330)
//            }
//        }
//    }
//}


import SwiftUI

struct GitCommitHistoryView: View {
    var commitHistories: [CommitHistory]?
    var user: User?
    let columns : Int // 
    let rows = 7

    var body: some View {
        let commitHistorySet = CommitHistoryViewModel.commitHistorySet(with: commitHistories ?? [], columnsCount: columns)
        
        VStack(alignment: .center,spacing: 5) {
            SkyView()
            VStack(alignment: .center) {
                GitCommitView(columns: columns, rows: 7, size: CGSize(width: 330, height: 230)) { row, column in
                    if let commitHistory = commitHistorySet.element(at: row)?.element(at: column) {
                        GitCommitCellView(commitHistory: commitHistory)
                    } else {
                        Text(" ")
                            .frame(width: 14, height: 14)
                    }
                }
            }
            FenceView()
                .frame(width: 350, height: 10)
            UserInfoView(user: user ?? User.defaultUser)
        }
        .padding(.horizontal, 20)
        .frame(width: 350,height: 400)
    }
}
