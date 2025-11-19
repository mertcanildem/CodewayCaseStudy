//
//  HomeViewModel.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import Photos
import Combine

final class HomeViewModel: ObservableObject {

    // Group list to be displayed on the Home screen
    @Published private(set) var sections: [GroupSection] = []

    // Scanning progress (for progress bar, label, etc.)
    @Published private(set) var progress: ScanProgress = .zero

    // Is scanning currently underway?
    @Published private(set) var isScanning: Bool = false

    private let photoLibraryService: PhotoLibraryService
    private let photoScanService: PhotoScanService
    private let persistenceService: PersistenceService

    // We keep GroupSections in a dictionary
    private var sectionsByKey: [String: GroupSection] = [:]

    // Total number of assets (entire library)
    private var totalAssetsCount: Int = 0

    // The first processed photo number we load from JSON when the app is opened
    private var initialProcessedCount: Int = 0

    // All PhotoItems processed so far (initial load + this run)
    private var allItems: [PhotoItem] = []

    // How often should we autosave — after how many photos?
    private let autosaveInterval = 50

    init(
        photoLibraryService: PhotoLibraryService = PhotoLibraryService(),
        photoScanService: PhotoScanService = PhotoScanService(),
        persistenceService: PersistenceService = .shared
    ) {
        self.photoLibraryService = photoLibraryService
        self.photoScanService = photoScanService
        self.persistenceService = persistenceService
    }

    // MARK: - Public API (HomeViewController'dan çağrılacak)

    func startScanning() {
        guard !isScanning else { return }

        isScanning = true
        sections = []
        sectionsByKey = [:]
        allItems = []
        initialProcessedCount = 0
        totalAssetsCount = 0
        progress = .zero

        photoLibraryService.requestAuthorizationIfNeeded { [weak self] granted in
            guard let self = self else { return }

            if !granted {
                self.isScanning = false
                return
            }

            // 1. Fetch all the assets
            let allAssets = self.photoLibraryService.fetchAllImageAssets()
            self.totalAssetsCount = allAssets.count

            // 2. If there exists a persistent scan, load it and find out which assets remain
            let remainingAssets = self.loadPersistedScan(using: allAssets)

            // If there is no remaining asset, everything has been done in advance
            if remainingAssets.isEmpty {
                self.isScanning = false
                return
            }

            // 3. Run scan for remaining assets only
            self.photoScanService.scan(
                assets: remainingAssets,
                onItemScanned: { [weak self] item, processedInThisRun, _ in
                    self?.handleScannedItem(item, processedInThisRun: processedInThisRun)
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.isScanning = false
                    // Tarama tamamlandığında tüm state'i kaydet
                    self.persistenceService.save(items: self.allItems)
                }
            )
        }
    }

    func numberOfNonEmptySections() -> Int {
        sections.filter { !$0.items.isEmpty }.count
    }

    func nonEmptySection(at index: Int) -> GroupSection {
        let filtered = sections.filter { !$0.items.isEmpty }
        return filtered[index]
    }

    func items(for group: PhotoGroup?) -> [PhotoItem] {
        let key = key(for: group)
        return sectionsByKey[key]?.items ?? []
    }

    // MARK: - Private helpers

    /// If there is a persistent scan, it loads it and fills the groups,
    /// then only the remaining assets (raw) are returned.
    private func loadPersistedScan(using allAssets: [PHAsset]) -> [PHAsset] {
        guard let persistedScan = persistenceService.load(),
              !persistedScan.items.isEmpty else {
            // Hiç daha önce kayıt yoksa progress 0'dan başlar
            progress = ScanProgress(processed: 0, total: allAssets.count)
            return allAssets
        }

        // id -> PHAsset map'i
        var assetById: [String: PHAsset] = [:]
        assetById.reserveCapacity(allAssets.count)
        for asset in allAssets {
            assetById[asset.localIdentifier] = asset
        }

        sectionsByKey = [:]
        sections = []
        allItems = []
        var processedIds = Set<String>()

        for persisted in persistedScan.items {
            guard let asset = assetById[persisted.id] else {
                // The photo may have been deleted, we are skipping it.
                continue
            }

            let item = PhotoItem(asset: asset, hash: persisted.hash)
            allItems.append(item)
            processedIds.insert(persisted.id)

            let key = key(for: item.group)
            var section = sectionsByKey[key] ?? GroupSection(group: item.group, items: [])
            section.items.append(item)
            sectionsByKey[key] = section
        }

        sections = sortSections(Array(sectionsByKey.values))
        initialProcessedCount = allItems.count

        // Progress by total asset count
        progress = ScanProgress(processed: initialProcessedCount, total: allAssets.count)

        // Remaining (not yet processed) assets
        let remainingAssets = allAssets.filter { !processedIds.contains($0.localIdentifier) }

        print("HomeViewModel: loaded \(initialProcessedCount) items from persisted scan, \(remainingAssets.count) remaining")

        return remainingAssets
    }

    private func handleScannedItem(_ item: PhotoItem, processedInThisRun: Int) {
        allItems.append(item)

        let key = key(for: item.group)
        var section = sectionsByKey[key] ?? GroupSection(group: item.group, items: [])
        section.items.append(item)
        sectionsByKey[key] = section

        sections = sortSections(Array(sectionsByKey.values))

        // Total number of processed photos processed in this run + pre-processed
        let overallProcessed = initialProcessedCount + processedInThisRun
        progress = ScanProgress(processed: overallProcessed, total: totalAssetsCount)

        persistProgressIfNeeded()
    }

    private func persistProgressIfNeeded() {
        guard !allItems.isEmpty else { return }

        if allItems.count % autosaveInterval == 0 {
            persistenceService.save(items: allItems)
        }
    }

    private func key(for group: PhotoGroup?) -> String {
        group?.rawValue ?? "others"
    }

    private func sortSections(_ sections: [GroupSection]) -> [GroupSection] {
        // Group order: a..t, then Others last
        let orderedGroups: [PhotoGroup?] = PhotoGroup.allCases.map { Optional($0) } + [nil]

        let orderMap: [String: Int] = Dictionary(
            uniqueKeysWithValues: orderedGroups.enumerated().map { index, group in
                let key = group?.rawValue ?? "others"
                return (key, index)
            }
        )

        return sections.sorted { lhs, rhs in
            let leftIndex = orderMap[lhs.id] ?? Int.max
            let rightIndex = orderMap[rhs.id] ?? Int.max
            return leftIndex < rightIndex
        }
    }
}


