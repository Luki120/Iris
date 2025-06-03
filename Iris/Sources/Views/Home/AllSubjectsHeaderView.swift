//
//  AllSubjectsHeaderView.swift
//  Iris
//
//  Created by Luki on 10/09/2024.
//

import UIKit

/// Class to represent the header for the all subjects section
final class AllSubjectsHeaderView: UICollectionReusableView {
	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(withStyle: .semiBold, size: 18)
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		return label
	}()

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		layoutUI()
	}

	// MARK: - Private

	private func layoutUI() {
		titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
	}
}
