//
//  PhotoScanService.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import Photos

final class PhotoScanService {

    private let queue = DispatchQueue(
        label: "PhotoScanService.queue",
        qos: .userInitiated
    )

    /// Scans the asset list in the background.
    /// For each item, onItemScanned is called when it is finished (main thread).
    func scan(
        assets: [PHAsset],
        onItemScanned: @escaping (_ item: PhotoItem, _ processed: Int, _ total: Int) -> Void,
        completion: @escaping () -> Void
    ) {
        guard !assets.isEmpty else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }

        queue.async {
            let total = assets.count
            var processed = 0

            for asset in assets {
                autoreleasepool {
                    let hash = asset.reliableHash()
                    let item = PhotoItem(asset: asset, hash: hash)
                    processed += 1

                    // UI update is always on main thread
                    DispatchQueue.main.async {
                        onItemScanned(item, processed, total)
                    }
                }
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
