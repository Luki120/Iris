import UIKit

@MainActor
protocol SubjectDetailsViewDelegate: AnyObject {
	func subjectDetailsView(_ subjectDetailsView: SubjectDetailsView, didTapAssignmentsCell forSubject: Subject)
}

/// Subjects detail view
final class SubjectDetailsView: UIView {
	private let viewModel: SubjectDetailsViewViewModel

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		group.edgeSpacing = .init(leading: nil, top: .fixed(10), trailing: nil, bottom: .fixed(10))

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

		return UICollectionViewCompositionalLayout(section: section)
	}()

	private lazy var subjectDetailsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		addSubview(collectionView)
		return collectionView
	}()

	weak var delegate: SubjectDetailsViewDelegate?

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		fatalError()
	}

	/// Designated initializer
	/// - Parameters:
	/// 	- viewModel: The view model object
	init(viewModel: SubjectDetailsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		pinViewToAllEdges(subjectDetailsCollectionView)

		viewModel.delegate = self
		viewModel.setupCollectionViewDiffableDataSource(for: subjectDetailsCollectionView)
	}
}

// MARK: - SubjectDetailsViewViewModelDelegate

extension SubjectDetailsView: SubjectDetailsViewViewModelDelegate {
	func didTapAssignmentsCell(for subject: Subject) {
		delegate?.subjectDetailsView(self, didTapAssignmentsCell: subject)
	}
}
