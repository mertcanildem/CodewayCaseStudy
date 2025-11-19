//
//  ScanProgress.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation

struct ScanProgress {
    let processed: Int
    let total: Int

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(processed) / Double(total)
    }

    static var zero: ScanProgress {
        ScanProgress(processed: 0, total: 0)
    }
}
