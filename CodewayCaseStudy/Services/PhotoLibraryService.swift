//
//  PhotoLibraryService.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import UIKit
import Photos

final class PhotoLibraryService {
    
    static let shared = PhotoLibraryService()   // In order to use it on SwiftUI side

    /// Gets permission from the user (if necessary) and returns the result.
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            }
        default:
            // denied, restricted vb.
            completion(false)
        }
    }

    /// Returns all photo assets (image only).
    func fetchAllImageAssets() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        // You can sort by creationDate if you want.
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]

        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var assets: [PHAsset] = []
        assets.reserveCapacity(result.count)

        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        return assets
    }
    
    func requestImage(
        for asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFill,
        highQuality: Bool = false,
        completion: @escaping (UIImage?) -> Void
    ) {
        let scale = UIScreen.main.scale
        let pixelSize = CGSize(width: targetSize.width * scale,
                               height: targetSize.height * scale)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        
        if highQuality {
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
        } else {
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
        }
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: pixelSize,
            contentMode: contentMode,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
