import UIKit

/// `UICollectionViewCell` subclass to represent the all subjects cell
final class AllSubjectsCell: UICollectionViewCell {
	private lazy var totalSubjectsLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	// MARK: - Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	// MARK: - Private

	private func setupUI() {
		contentView.backgroundColor = .secondarySystemGroupedBackground
		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 15

		layoutUI()
	}

	private func layoutUI() {
		totalSubjectsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		totalSubjectsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
	}
}

// MARK: - Public

extension AllSubjectsCell {
	/// Function to configure the cell with its respective view model
	/// - Parameter viewModel: The view model object
	func configure(with viewModel: AllSubjectsCellViewModel) {
		totalSubjectsLabel.attributedText = .init(
			fullString: String(describing: viewModel.count) + "\n" + viewModel.title,
			subString: viewModel.title
		)
	}
}

private extension NSAttributedString {
	convenience init(fullString: String, subString: String) {
		var attributedString = AttributedString(fullString)

		guard let subRange = attributedString.range(of: subString) else {
			self.init(attributedString)
			return
		}

		let fullStringFont: UIFont = .quicksand(withStyle: .semiBold, size: 50)
		let subStringFont: UIFont = .quicksand(withStyle: .medium, size: 18)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.paragraphSpacing = 0.05 * fullStringFont.lineHeight

		let fullStringAttributes = AttributeContainer()
			.font(fullStringFont)
			.foregroundColor(.label)
			.paragraphStyle(paragraphStyle)

		let subAttributes = AttributeContainer()
			.font(subStringFont)
			.foregroundColor(.systemGray)

		attributedString.setAttributes(fullStringAttributes)
		attributedString[subRange].setAttributes(subAttributes)

		self.init(attributedString)
	}
}

extension NSParagraphStyle: @unchecked @retroactive Sendable {}
