import UIKit

@MainActor
protocol HomeViewViewModelDelegate: AnyObject {
	func didTapAllSubjectsCell()
	func didTap(subject: Subject)
}

/// View model class for `HomeView`
@MainActor
final class HomeViewViewModel: NSObject {
	let nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""

	// MARK: - UICollectionViewDiffableDataSource

	@MainActor
	fileprivate struct Item {
		fileprivate let id = UUID()
		fileprivate let viewModel: AnyHashable
	}

	@MainActor
	struct Section: Hashable {
		fileprivate let viewModels: [Item]

		static let allSubjects: Section = .init(
			viewModels: [.init(viewModel: AllSubjectsCellViewModel(count: 35, title: "Subjects"))]
		)

		static let currentlyTakingSubjects: Section = .init(viewModels: [])
	}

	let sections: [Section] = [.allSubjects, .currentlyTakingSubjects]

	private typealias AllSubjectsCellRegistration = UICollectionView.CellRegistration<AllSubjectsCell, AllSubjectsCellViewModel>
	private typealias CurrentlyTakingSubjectCellRegistration = UICollectionView.CellRegistration<CurrentlyTakingSubjectCell, CurrentlyTakingSubjectCellViewModel>

	private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<AllSubjectsHeaderView>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

	private var dataSource: DataSource!

	private let allSubjectsCellRegistration = AllSubjectsCellRegistration { cell, _, viewModel in
		cell.configure(with: viewModel)
	}

	private let currentlyTakingSubjectCellRegistration = CurrentlyTakingSubjectCellRegistration { cell, _, viewModel in
		cell.configure(with: viewModel)
	}

	weak var delegate: HomeViewViewModelDelegate?

	private var collectionView: UICollectionView!

	override init() {
		super.init()
		observeSubjects()
	}

	private func observeSubjects() {
		withObservationTracking {
			let _ = SubjectsManager.shared.currentlyTakingSubjects
		} onChange: {
			Task { @MainActor [weak self] in
				guard let self else { return }
				applySnapshot(withModels: SubjectsManager.shared.currentlyTakingSubjects)

				guard let headerView = collectionView.supplementaryView(
					forElementKind: UICollectionView.elementKindSectionHeader,
					at: IndexPath(row: 0, section: 1)
				) as? AllSubjectsHeaderView else { return }

				headerView.titleLabel.text = SubjectsManager.shared.currentlyTakingSubjects.isEmpty ? "" : "Currently taking"

				observeSubjects()
			}
		}
	}

	/// Function to fetch the profile picture image
	/// - Returns: `UIImage?`
	nonisolated func fetchImage() async -> UIImage? {
		guard let url = URL(string: .githubImageURL) else { return nil }

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			return UIImage(data: data)
		}
		catch {
			print(error.localizedDescription)
		}

		return nil
	}
}

// MARK: - UICollectionView

extension HomeViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
			guard let self else { fatalError() }
			self.collectionView = collectionView

			switch sections[indexPath.section] {
				case .allSubjects:
					guard let allSubjectsViewModel = item.viewModel as? AllSubjectsCellViewModel else { fatalError() }

					return collectionView.dequeueConfiguredReusableCell(
						using: allSubjectsCellRegistration,
						for: indexPath,
						item: allSubjectsViewModel
					)

				case .currentlyTakingSubjects:
					guard let currentlyTakingSubjectViewModel = item.viewModel as? CurrentlyTakingSubjectCellViewModel else { fatalError() }

					return collectionView.dequeueConfiguredReusableCell(
						using: currentlyTakingSubjectCellRegistration,
						for: indexPath,
						item: currentlyTakingSubjectViewModel
					)

				default: fatalError()
			}
		}
		setupHeaderRegistration()
		applySnapshot(withModels: SubjectsManager.shared.currentlyTakingSubjects)
	}

	private func setupHeaderRegistration() {
		let headerRegistration = HeaderRegistration(
			elementKind: UICollectionView.elementKindSectionHeader
		) { headerView, _, indexPath in
			let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			switch section {
				case .currentlyTakingSubjects:
					headerView.titleLabel.text = SubjectsManager.shared.currentlyTakingSubjects.isEmpty ? "" : "Currently taking"

				default: break
			}
		}
		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			guard kind == UICollectionView.elementKindSectionHeader else { return nil }
			return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
		}
	}

	private func applySnapshot(withModels models: [Subject]) {
		guard let dataSource else { return }

		var snapshot = Snapshot()
		snapshot.appendSections(sections)

		let mappedModels = models.compactMap { Item(viewModel: CurrentlyTakingSubjectCellViewModel($0)) }

		for (index, section) in sections.enumerated() {
			switch index {
				case 0: snapshot.appendItems(section.viewModels, toSection: section)
				case 1: snapshot.appendItems(mappedModels, toSection: section)
				default: break
			}
		}
		dataSource.apply(snapshot)
	}
}

extension HomeViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch sections[indexPath.section] {
			case .allSubjects: delegate?.didTapAllSubjectsCell()
			case .currentlyTakingSubjects: delegate?.didTap(
				subject: SubjectsManager.shared.currentlyTakingSubjects[indexPath.item]
			)
			default: break
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard let indexPath = indexPaths.first else { return nil }

		switch sections[indexPath.section] {
			case .currentlyTakingSubjects:
				let contextMenu = UIContextMenuConfiguration(previewProvider: nil) { _ in
					let subject = SubjectsManager.shared.currentlyTakingSubjects[indexPath.item]

					let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
						SubjectsManager.shared.delete(subject: subject, at: indexPath.item)
						self.dataSource.apply(self.dataSource.snapshot())
					}
					let passedAction = UIAction(title: "Passed", image: UIImage(systemName: "checkmark")) { _ in
						SubjectsManager.shared.passed(subject: subject, at: indexPath.item)
						self.dataSource.apply(self.dataSource.snapshot())
					}

					guard subject.finalGrades.isEmpty else {
						return UIMenu(options: .displayInline, children: [passedAction, deleteAction])
					}
					return UIMenu(options: .displayInline, children: [deleteAction])
				}
				return contextMenu

			default: return nil
		}
	}
}

nonisolated extension HomeViewViewModel.Item: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: HomeViewViewModel.Item, rhs: HomeViewViewModel.Item) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
