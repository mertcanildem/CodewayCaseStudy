//
//  GroupDetailViewModel.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import Combine

final class GroupDetailViewModel: ObservableObject {

    @Published private(set) var items: [PhotoItem]
    let title: String

    init(section: GroupSection) {
        self.items = section.items
        self.title = section.title
    }

    func item(at index: Int) -> PhotoItem {
        items[index]
    }
}
