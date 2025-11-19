//
//  ImageDetailView.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import SwiftUI
import UIKit
import Photos

struct ImageDetailView: View {

    @ObservedObject var viewModel: ImageDetailViewModel
    @State private var images: [Int: UIImage] = [:]   // index -> image cache

    var body: some View {
        ZStack(alignment: .bottom) {
            // left-right Switch between photos with swipe
            TabView(selection: $viewModel.selectedIndex) {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    ZStack {
                        Color.black.ignoresSafeArea()

                        if let image = images[index] {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity)
                                .background(Color.black)
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .tag(index)
                    .onAppear {
                        loadImageIfNeeded(for: index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.black.edgesIgnoringSafeArea(.all))

            // Small info bar at the bottom
            HStack {
                Text("\(viewModel.selectedIndex + 1) / \(viewModel.items.count)")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.85))

                Spacer()
            }
            .padding()
            .background(
                Color.black
                    .opacity(0.4)
                    .blur(radius: 10)
            )
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Image Loading

    private func loadImageIfNeeded(for index: Int) {
        guard images[index] == nil else { return }

        let item = viewModel.items[index]
        let screenSize = UIScreen.main.bounds.size

        PhotoLibraryService.shared.requestImage(
            for: item.asset,
            targetSize: screenSize,
            contentMode: .aspectFit,
            highQuality: true
        ) { uiImage in
            guard let uiImage = uiImage else { return }
            images[index] = uiImage
        }
    }
}



//#Preview {
//    ImageDetailView()
//}
