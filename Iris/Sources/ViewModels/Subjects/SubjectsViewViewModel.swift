import UIKit

/// View model class for `SubjectsView`
@MainActor
final class SubjectsViewViewModel: NSObject {
	private var subjects = [Subject]() {
		didSet {
			viewModels += subjects.compactMap { subject in
				return SubjectCellViewModel(name: subject.name)
			}
		}
	}

	private var viewModels = [SubjectCellViewModel]()

	// MARK: - UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<SubjectCell, SubjectCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, SubjectCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SubjectCellViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}

	override init() {
		super.init()
		fetchSubjects()
	}

	private func fetchSubjects() {
		guard let url = URL(string: SubjectsService.Constants.baseURL) else { return }

		Task {
			guard let subjects = try? await SubjectsService.shared.fetchSubjects(withURL: url) else { return }

			self.subjects = subjects.map { .init(from: $0) }
			self.applyDiffableDataSourceSnapshot()
		}
	}
}

// MARK: - UICollectionView

extension SubjectsViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(viewModels)
		dataSource.apply(snapshot)
	}
}

extension SubjectsViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		SubjectsManager.shared.takeSubject(subjects[indexPath.item])
	}
}
