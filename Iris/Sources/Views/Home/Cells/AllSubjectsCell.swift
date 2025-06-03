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
	/// -  Parameters:
	/// 	- with: The view model object
	func configure(with viewModel: AllSubjectsCellViewModel) {
		totalSubjectsLabel.attributedText = .init(
			fullString: String(describing: viewModel.count) + "\n" + viewModel.title,
			subString: viewModel.title
		)
	}
}

private extension NSAttributedString {
	convenience init(fullString: String, subString: String) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		let fullStringFont: UIFont = .quicksand(withStyle: .semiBold, size: 50)
		let subStringFont: UIFont = .quicksand(withStyle: .medium, size: 18)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.paragraphSpacing = 0.05 * fullStringFont.lineHeight

		attributedString.addAttribute(NSAttributedString.Key.font, value: fullStringFont, range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.font, value: subStringFont, range: rangeOfSubString)
		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: rangeOfSubString)
		attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: rangeOfFullString)

		self.init(attributedString: attributedString)
	}
}
