import UIKit

@MainActor
protocol HomeViewDelegate: AnyObject {
	func didTapAllSubjectsCell(in: HomeView)
	func didTapProfilePictureButton(in: HomeView)
	func homeView(_ homeView: HomeView, didTap subject: Subject)
}

/// Home view
final class HomeView: UIView {
	private let viewModel = HomeViewViewModel()

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
			return self?.createSection(for: sectionIndex, layoutEnvironment: layoutEnvironment)
		}
		return layout
	}()

	private lazy var subjectsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		addSubview(collectionView)
		return collectionView
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private(set) lazy var profilePictureButton: UIButton = {
		let button = UIButton()
		button.frame = .init(x: 0, y: 0, width: 35, height: 35)
		button.imageView?.alpha = 0
		button.imageView?.contentMode = .scaleAspectFit
		button.imageView?.layer.cornerRadius = button.frame.height / 2
		button.imageView?.layer.masksToBounds = true
		button.addAction(UIAction { _ in self.delegate?.didTapProfilePictureButton(in: self) }, for: .touchUpInside)
		return button
	}()

	weak var delegate: HomeViewDelegate?

	var nickname: String { viewModel.nickname }

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		pinViewToAllEdges(subjectsCollectionView)

		viewModel.delegate = self
		viewModel.setupDiffableDataSource(for: subjectsCollectionView)
	}

	// MARK: - Private

	private func createTitle() -> String {
		let hour = Calendar.current.component(.hour, from: .now)

		switch hour {
			case 6..<12: return "Good morning, \(nickname)"
			case 12..<18: return "Good afternoon, \(nickname)"
			case 18..<22: return "Good evening, \(nickname)"
			default: return "Good night, \(nickname)"
		}
	}

	private func setupUI() {
		titleLabel.attributedText = .init(fullString: createTitle(), subString: nickname)

		profilePictureButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
		profilePictureButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

		fetchImage()
	}

	private func fetchImage() {
		Task {
			let image = await self.viewModel.fetchImage()

			await MainActor.run {
				UIView.transition(with: self.profilePictureButton.imageView!, duration: 0.5) {
					self.profilePictureButton.imageView?.alpha = 1
					self.profilePictureButton.setImage(image, for: .normal)
				}
			}
		}
	}
}

// MARK: - UICollectionViewCompositionalLayout

private extension HomeView {
	private func createAllSubjectsLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(180))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let containerWidth = layoutEnvironment.container.effectiveContentSize.width
		let cellWidth = containerWidth * group.layoutSize.widthDimension.dimension
		let horizontalSpacing = (containerWidth - cellWidth) / 2

		group.edgeSpacing = .init(leading: .fixed(horizontalSpacing), top: .fixed(10), trailing: .fixed(horizontalSpacing), bottom: .fixed(10))

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
		return section
	}

	private func createCurrentlyTakingSubjectsLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		group.edgeSpacing = .init(leading: nil, top: .fixed(10), trailing: nil, bottom: .fixed(10))

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
		createHeader(for: section)
		return section
	}

	private func createHeader(for section: NSCollectionLayoutSection) {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .top
		)
		section.boundarySupplementaryItems = [sectionHeader]
	}

	private func createSection(for sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
		switch viewModel.sections[sectionIndex] {
			case .allSubjects: return createAllSubjectsLayout(layoutEnvironment: layoutEnvironment)
			case .currentlyTakingSubjects: return createCurrentlyTakingSubjectsLayout()
			default: return nil
		}
	}
}

// MARK: - HomeViewViewModelDelegate

extension HomeView: HomeViewViewModelDelegate {
	func didTapAllSubjectsCell() {
		delegate?.didTapAllSubjectsCell(in: self)
	}

	func didTap(subject: Subject) {
		delegate?.homeView(self, didTap: subject)
	}
}

private extension NSAttributedString {
	convenience init(fullString: String, subString: String) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		let fullStringFont: UIFont = .quicksand(style: .semiBold, size: 22)
		let subStringFont: UIFont = .quicksand(style: .bold, size: 22)

		attributedString.addAttribute(.font, value: fullStringFont, range: rangeOfFullString)
		attributedString.addAttribute(.font, value: subStringFont, range: rangeOfSubString)
		attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray, range: rangeOfFullString)
		attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}
