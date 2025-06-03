//
//  SettingsViewViewModel.swift
//  Iris
//
//  Created by Luki on 19/09/2024.
//

import Foundation
import SwiftUI
import UIKit.UICollectionView

@MainActor
protocol SettingsViewViewModelDelegate: AnyObject {
	func didTapCell(at indexPath: IndexPath)
}

/// View model class for `SettingsView`
@MainActor
final class SettingsViewViewModel: NSObject {
	weak var delegate: SettingsViewViewModelDelegate?

	// MARK: - UICollectionViewDiffableDataSource

	fileprivate enum CellType: Hashable {
		case developer(DeveloperCellViewViewModel)
		case accountSettings([AccountSettingsCellViewViewModel])
		case sourceCode(SourceCodeCellViewViewModel)
	}

	private enum Section: String {
		case developer = "Developer"
		case accountSettings = "Settings"
		case sourceCode = "View the source"

		var title: String { rawValue }
	}

	private let cells: [CellType] = [
		.developer(.init(name: "Luki120")),
		.accountSettings([.init(action: "Sign out"), .init(action: "Delete account"), .init(action: "Purge all data")]),
		.sourceCode(.init(title: "Source code"))
	]

	private typealias DeveloperCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DeveloperCellViewViewModel>
	private typealias AccountSettingsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AccountSettingsCellViewViewModel>
	private typealias SourceCodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SourceCodeCellViewViewModel>

	private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
	private typealias FooterRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	private let developerCellRegistration = DeveloperCellRegistration { cell, _, viewModel in
		cell.contentConfiguration = UIHostingConfiguration {
			DeveloperCellView(viewModel: viewModel)
		}
		cell.secondaryGroupedBackgroundConfiguration()
	}
	private let accountSettingsCellRegistration = AccountSettingsCellRegistration { cell, indexPath, viewModel in
		var configuration = cell.defaultContentConfiguration()
		configuration.text = viewModel.action
		configuration.textProperties.font = .quicksand(withStyle: .medium)
		configuration.textProperties.color = indexPath.item == 0 ? .label : .systemRed

		cell.contentConfiguration = configuration
		cell.secondaryGroupedBackgroundConfiguration()
	}
	private let sourceCodeCellRegistration = SourceCodeCellRegistration { cell, _, viewModel in
		var configuration = cell.defaultContentConfiguration()
		configuration.text = viewModel.title
		configuration.textProperties.font = .quicksand(withStyle: .medium)

		cell.contentConfiguration = configuration
		cell.secondaryGroupedBackgroundConfiguration()
	}
}

// MARK: - UICollectionView

extension SettingsViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
			guard let self else { fatalError() }

			switch cells[indexPath.section] {
				case .developer(let viewModel):
					return collectionView.dequeueConfiguredReusableCell(
						using: developerCellRegistration,
						for: indexPath,
						item: viewModel
					)

				case .accountSettings(let viewModels):
					return collectionView.dequeueConfiguredReusableCell(
						using: accountSettingsCellRegistration,
						for: indexPath,
						item: viewModels[indexPath.item]
					)

				case .sourceCode(let viewModel):
					return collectionView.dequeueConfiguredReusableCell(
						using: sourceCodeCellRegistration,
						for: indexPath,
						item: viewModel
					)
			}
		}
		setupSupplementaryRegistration()
		applyDiffableDataSourceSnapshot()
	}

	private func setupSupplementaryRegistration() {
		let headerRegistration = HeaderRegistration(
			elementKind: UICollectionView.elementKindSectionHeader
		) { headerView, _, indexPath in
			let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			var configuration = headerView.defaultContentConfiguration()
			configuration.text = section.title
			configuration.textProperties.font = .quicksand(withStyle: .medium, size: 14)

			headerView.contentConfiguration = configuration
		}

		let footerRegistration = FooterRegistration(
			elementKind: UICollectionView.elementKindSectionFooter
		) { footerView, _, indexPath in
			footerView.contentConfiguration = UIHostingConfiguration {
				SettingsFooterView()
			}
		}

		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			if kind == UICollectionView.elementKindSectionHeader {
				return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)

			}
			else {
				return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
			}
		}
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.developer, .accountSettings, .sourceCode])
		snapshot.appendItems(cells.filter(\.isDeveloper), toSection: .developer)

		if case .accountSettings(let viewModels) = cells.first(where: \.isAccountSettings) {
			let accountSettingsCells = viewModels.map { AccountSettingsCellViewViewModel(action: $0.action) }
			snapshot.appendItems(accountSettingsCells.map { .accountSettings([$0]) }, toSection: .accountSettings)
		}
		snapshot.appendItems(cells.filter(\.isSourceCode), toSection: .sourceCode)
		dataSource.apply(snapshot)
	}
}

extension SettingsViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didTapCell(at: indexPath)
	}
}

extension UICollectionViewListCell {
	func secondaryGroupedBackgroundConfiguration() {
		self.configurationUpdateHandler = { cell, _ in
			var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
			backgroundConfig.backgroundColor = .secondarySystemGroupedBackground
			cell.backgroundConfiguration = backgroundConfig
		}
	}
}

extension SettingsViewViewModel.CellType {
	var isDeveloper: Bool {
		guard case .developer = self else { return false }
		return true
	}
	var isAccountSettings: Bool {
		guard case .accountSettings = self else { return false }
		return true
	}
	var isSourceCode: Bool {
		guard case .sourceCode = self else { return false }
		return true
	}
}
