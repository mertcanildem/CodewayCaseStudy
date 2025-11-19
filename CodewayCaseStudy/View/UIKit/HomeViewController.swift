//
//  HomeViewController.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import UIKit
import Combine
import SwiftUI   // In order to push SwiftUI Views

final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    private var collectionView: UICollectionView!
    private let progressLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCollectionView()
        setupProgressViews()
        setupLayout()
        bindViewModel()

        // Scanning starts here:
        viewModel.startScanning()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Photo Groups"
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            GroupCollectionViewCell.self,
            forCellWithReuseIdentifier: GroupCollectionViewCell.reuseIdentifier
        )

        view.addSubview(collectionView)
    }

    private func setupProgressViews() {
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textColor = .secondaryLabel
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Scanning photos..."

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0

        view.addSubview(progressLabel)
        view.addSubview(progressView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        // Update collectionView when sections change
        viewModel.$sections
            .map { sections in
                sections.filter { !$0.items.isEmpty }.count    // number of full groups
            }
            .removeDuplicates()                               // If the same number comes up again, do not reload.
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &subscriptions)

        // Update label + bar when progress changes
        viewModel.$progress
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                if progress.total == 0 {
                    self.progressLabel.text = "Scanning photos..."
                    self.progressView.setProgress(0, animated: false)
                } else {
                    let percent = Int(progress.fraction * 100)

                    self.progressLabel.text = String(
                        format: "Scanning photos: %d%% (%d / %d)",
                        percent,
                        progress.processed,
                        progress.total
                    )

                    self.progressView.setProgress(Float(progress.fraction), animated: true)
                }
            }
            .store(in: &subscriptions)

        // Update the label after isScanning is finished
        viewModel.$isScanning
            .receive(on: RunLoop.main)
            .sink { [weak self] isScanning in
                guard let self = self else { return }
                guard !isScanning else { return }

                let progress = self.viewModel.progress
                if progress.total > 0 {
                    let percent = Int(progress.fraction * 100)
                    self.progressLabel.text = String(
                        format: "Scan completed: %d%% (%d / %d)",
                        percent,
                        progress.processed,
                        progress.total
                    )
                    self.progressView.setProgress(Float(progress.fraction), animated: true)
                } else {
                    self.progressLabel.text = "Scan completed"
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - Navigation

    private func showGroupDetail(for section: GroupSection) {
        let items = section.items

        let detailViewModel = GroupDetailViewModel(section: section)
        let detailView = GroupDetailView(viewModel: detailViewModel)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.title = section.title

        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfNonEmptySections()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GroupCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? GroupCollectionViewCell else {
            return UICollectionViewCell()
        }

        let section = viewModel.nonEmptySection(at: indexPath.item)
        cell.configure(with: section)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let section = viewModel.nonEmptySection(at: indexPath.item)
        showGroupDetail(for: section)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalHorizontalPadding: CGFloat = 12 + 12 + 12 // left + right + spacing
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let itemWidth = availableWidth / 2  // 2 column

        return CGSize(width: itemWidth, height: 150)
    }
}

//#Preview {
//    HomeViewController()
//}
