//
//  GroupSection.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation

struct GroupSection: Identifiable {
    let id: String               // group key
    let group: PhotoGroup?       // nil -> Others
    var items: [PhotoItem]

    var title: String {
        if let group = group {
            return "Group \(group.rawValue.uppercased())"
        } else {
            return "Others"
        }
    }

    var countText: String {
        "\(items.count) photos"
    }

    init(group: PhotoGroup?, items: [PhotoItem] = []) {
        self.group = group
        self.items = items
        self.id = group?.rawValue ?? "others"
    }
}
