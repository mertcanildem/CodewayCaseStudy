//
//  GroupDetailView.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import SwiftUI

struct GroupDetailView: View {

    @ObservedObject var viewModel: GroupDetailViewModel

    // 3 column grid
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(viewModel.items.enumerated()), id: \.1.id) { index, item in
                    NavigationLink {
                        let detailVM = ImageDetailViewModel(items: viewModel.items, selectedIndex: index)
                        ImageDetailView(viewModel: detailVM)
                    } label: {
                        PhotoThumbnailView(item: item)
                    }
                }
            }
            .padding(8)
        }
        .navigationTitle(viewModel.title)
    }
}



//#Preview {
//    GroupDetailView()
//}
