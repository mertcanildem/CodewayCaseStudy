//
//  PhotoThumbnailView.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import SwiftUI

import Photos
import UIKit

struct PhotoThumbnailView: View {

    let item: PhotoItem
    private let size: CGFloat

    @State private var image: UIImage?

    init(item: PhotoItem, size: CGFloat = 120) {
        self.item = item
        self.size = size
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))

                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(8)
        .onAppear {
            loadImageIfNeeded()
        }
    }

    private func loadImageIfNeeded() {
        guard image == nil else { return }

        PhotoLibraryService.shared.requestImage(
            for: item.asset,
            targetSize: CGSize(width: size, height: size)
        ) { uiImage in
            self.image = uiImage
        }
    }
}

//#Preview {
//    PhotoThumbnailView()
//}
