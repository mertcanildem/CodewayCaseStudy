//
//  RootView.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import Foundation
import SwiftUI
import UIKit

struct RootView: UIViewControllerRepresentable {

    // The controller type we will display on the UIKit side
    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(context: Context) -> UINavigationController {
        // Create ViewModel
        let homeViewModel = HomeViewModel()

        // Create HomeViewController
        let homeVC = HomeViewController(viewModel: homeViewModel)

        // Put it in the navigation controller
        let navController = UINavigationController(rootViewController: homeVC)
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // This is empty for now, we are not doing anything dynamic.
    }
}
