//
//  PersistenceService.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation

// The simple model we will write to JSON
struct PersistedPhotoItem: Codable {
    let id: String    // asset.localIdentifier
    let hash: Double
}

struct PersistedScan: Codable {
    let items: [PersistedPhotoItem]
    let date: Date
}

final class PersistenceService {

    static let shared = PersistenceService()

    private init() { }

    private var fileURL: URL? {
        do {
            let docs = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return docs.appendingPathComponent("photo_scan.json")
        } catch {
            print("PersistenceService: error finding documents dir: \(error)")
            return nil
        }
    }

    // MARK: - Save

    func save(items: [PhotoItem]) {
        guard let url = fileURL else { return }

        let persistedItems = items.map {
            PersistedPhotoItem(id: $0.id, hash: $0.hash)
        }

        let scan = PersistedScan(items: persistedItems, date: Date())

        do {
            let data = try JSONEncoder().encode(scan)
            try data.write(to: url, options: .atomic)
            print("PersistenceService: saved \(items.count) items to \(url.lastPathComponent)")
        } catch {
            print("PersistenceService: failed to save - \(error)")
        }
    }

    // MARK: - Load

    func load() -> PersistedScan? {
        guard let url = fileURL else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let scan = try JSONDecoder().decode(PersistedScan.self, from: data)
            print("PersistenceService: loaded \(scan.items.count) items")
            return scan
        } catch {
            print("PersistenceService: failed to load - \(error)")
            return nil
        }
    }

    func clear() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
