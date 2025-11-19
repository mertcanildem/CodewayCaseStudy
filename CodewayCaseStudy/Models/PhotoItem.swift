//
//  PhotoItem.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import Photos

struct PhotoItem: Identifiable {
    let id: String               // asset.localIdentifier
    let asset: PHAsset
    let hash: Double
    let group: PhotoGroup?       // nil -> "Others"

    init(asset: PHAsset, hash: Double) {
        self.asset = asset
        self.id = asset.localIdentifier
        self.hash = hash
        self.group = PhotoGroup.group(for: hash)
    }
}
