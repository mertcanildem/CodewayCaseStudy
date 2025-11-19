//
//  ImageDetailViewModel.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import Combine

final class ImageDetailViewModel: ObservableObject {

    @Published private(set) var items: [PhotoItem]
    @Published var selectedIndex: Int

    var currentItem: PhotoItem {
        items[selectedIndex]
    }

    init(items: [PhotoItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
    }

    func goToNext() {
        guard selectedIndex < items.count - 1 else { return }
        selectedIndex += 1
    }

    func goToPrevious() {
        guard selectedIndex > 0 else { return }
        selectedIndex -= 1
    }
}
