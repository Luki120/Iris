//
//  SubjectDetailsTasksCell.swift
//  Iris
//
//  Created by Luki on 08/09/2024.
//

import UIKit

/// `UICollectionViewCell` to represent the tasks cell
final class SubjectDetailsAssignmentsCell: UICollectionViewCell {
	private lazy var tasksImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15))
		imageView.tintColor = .white
		imageView.contentMode = .center
		imageView.backgroundColor = .irisSlateBlue
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
		imageView.layer.cornerRadius = 15
		contentView.addSubview(imageView)
		return imageView
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(style: .semiBold, size: 18)
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	private lazy var arrowLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(style: .semiBold, size: 20)
		label.text = "→"
		label.textColor = .systemGray
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemGroupedBackground
		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 15

		layoutUI()
	}

	// MARK: - Private

	private func layoutUI() {
		NSLayoutConstraint.activate([
			tasksImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			tasksImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			tasksImageView.widthAnchor.constraint(equalToConstant: 30),
			tasksImageView.heightAnchor.constraint(equalToConstant: 30),

			titleLabel.topAnchor.constraint(equalTo: tasksImageView.bottomAnchor, constant: 10),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			titleLabel.leadingAnchor.constraint(equalTo: tasksImageView.leadingAnchor),

			arrowLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			arrowLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
}

// MARK: - Public

extension SubjectDetailsAssignmentsCell {
	/// Function to configure the cell with its respective view model
	///	- Parameter viewModel: The view model object
	func configure(with viewModel: SubjectDetailsAssignmentsCellViewModel) {
		titleLabel.text = viewModel.title
	}
}
