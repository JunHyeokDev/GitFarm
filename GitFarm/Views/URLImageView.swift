//
//  URLImageView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/9/24.
//

import SwiftUI

struct URLImageView: View {
    
    let urlString : String
    let width : CGFloat
    let height : CGFloat
    
    init(urlString: String, width: CGFloat, height: CGFloat) {
        self.urlString = urlString
        self.width = width
        self.height = height
    }
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                Color.gray
                    .frame(width: width,height: height)
                    .clipShape(Circle())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: width,height: height)

            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width,height: height)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
