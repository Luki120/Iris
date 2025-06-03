import UIKit

/// Class to represent the subjects view
final class SubjectsView: UIView {
	private let viewModel = SubjectsViewViewModel()

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		group.edgeSpacing = .init(leading: nil, top: .fixed(10), trailing: nil, bottom: .fixed(10))

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

		return UICollectionViewCompositionalLayout(section: section)
	}()

	private lazy var subjectsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		addSubview(collectionView)
		return collectionView
	}()

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		pinViewToAllEdges(subjectsCollectionView)

		viewModel.setupCollectionViewDiffableDataSource(for: subjectsCollectionView)
	}
}
