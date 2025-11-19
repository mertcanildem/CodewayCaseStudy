//
//  GroupCollectionViewCell.swift
//  CodewayCaseStudy
//
//  Created by Mert can Ildem on 14.11.2025.
//

import UIKit
import Photos

final class GroupCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "GroupCollectionViewCell"

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    // To set the correct image during reuse
    private var currentItemId: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        thumbnailImageView.image = nil
//        currentItemId = nil
    }

    private func setupViews() {
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = UIFont.systemFont(ofSize: 14)
        countLabel.textColor = .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Thumbnail on top
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 90),

            // Title
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),

            // Count
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),
            countLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with section: GroupSection) {
        titleLabel.text = section.title
        countLabel.text = section.countText

        guard let firstItem = section.items.first else {
            thumbnailImageView.image = nil
            currentItemId = nil
            return
        }

        // If this cell is already configured for this first photo, do nothing
        if currentItemId == firstItem.id {
            return
        }

        currentItemId = firstItem.id
        thumbnailImageView.image = nil

        let targetSize = CGSize(width: 160, height: 90)

        PhotoLibraryService.shared.requestImage(
            for: firstItem.asset,
            targetSize: targetSize,
            contentMode: .aspectFill
        ) { [weak self] image in
            guard let self = self else { return }
            // Reuse protection
            guard self.currentItemId == firstItem.id else { return }
            self.thumbnailImageView.image = image
        }
    }

}


//#Preview {
//    GroupCollectionViewCell()
//}
