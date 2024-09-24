//
//  SettingsView.swift
//  Iris
//
//  Created by Luki on 19/09/2024.
//

import UIKit

protocol SettingsViewDelegate: AnyObject  {
	func settingsView(_ settingsView: SettingsView, didTapCellAt: IndexPath)
}

/// View that'll show the settings view
final class SettingsView: UIView {

	private let viewModel = SettingsViewViewModel()

	private lazy var settingsCollectionView: UICollectionView = {
		let sectionProvider = { sectionIndex, layoutEnvironment in
			var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
			listConfig.headerMode = .supplementary
			listConfig.footerMode = sectionIndex == 2 ? .supplementary : .none
			return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
		}
		let listLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	weak var delegate: SettingsViewDelegate?

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		pinViewToAllEdges(settingsCollectionView)

		viewModel.delegate = self
		viewModel.setupCollectionViewDiffableDataSource(for: settingsCollectionView)
	}

}

// MARK: - SettingsViewViewModelDelegate

extension SettingsView: SettingsViewViewModelDelegate {
	func didTapCell(at indexPath: IndexPath) {
		delegate?.settingsView(self, didTapCellAt: indexPath)
	}
}
