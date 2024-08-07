//
//  GitFarmWidgetEntryView.swift
//  GitFarmWidgetExtension
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

import SwiftUI
import WidgetKit

struct GitFarmWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if entry.isLoading {
                    improvedLoadingView
                } else if let user = entry.user, let commitHistories = entry.commitHistories {
                    contentView(user: user, commitHistories: commitHistories)
                } else {
                    Text("No data available")
                }
                
                refreshButton(geometry: geometry)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Updating...")
                .font(.caption)
        }
    }
    
    private var improvedLoadingView: some View {
        ZStack {
            // 배경
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack {
                // 로고 또는 아이콘 (예: SF Symbols 사용)
                Image(systemName: "leaf.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.green)
                    .offset(y:40)
                ZStack{
                    // 로딩 인디케이터
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding()
                    
                    // 텍스트
                    Text("Updating Git Farm...")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func contentView(user: User, commitHistories: [CommitHistory]) -> some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .systemMedium:
                GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .systemLarge:
                GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
            case .accessoryRectangular:
                GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
            default:
                Text("Unsupported widget size")
            }
        }
    }
    
    private func refreshButton(geometry: GeometryProxy) -> some View {
        VStack {
            Button(intent: RefreshWidgetIntent()) {
                Color.clear
                    .frame(width: 30, height: 30)
                
            }
            .buttonStyle(.plain) // 버튼이 사라지는 마법!!
            .position(x: geometry.size.width / 2, y: 9)
            
            Spacer()
        }
    }
}


struct GIFImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        if let path = Bundle.main.path(forResource: name, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            imageView.loadGif(url: url)
        }
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

extension UIImageView {
    func loadGif(url: URL) {
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.animate(withGIFData: imageData)
                }
            }
        }
    }

    private func animate(withGIFData data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        
        self.animationImages = images
        self.animationDuration = Double(imageCount) * 0.1
        self.animationRepeatCount = 0 // 0 means infinite
        self.startAnimating()
    }
}
