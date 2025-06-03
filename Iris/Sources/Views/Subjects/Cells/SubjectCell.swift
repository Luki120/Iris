import UIKit

/// `UICollectionViewCell` subclass to represent the subject cell
class SubjectCell: UICollectionViewCell {
	private(set) lazy var subjectNameLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(withStyle: .bold)
		label.adjustsFontSizeToFitWidth = true
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
		subjectNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		subjectNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		subjectNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}
}

// MARK: - Public

extension SubjectCell {
	/// Function to configure the cell with its respective view model
	/// -  Parameters:
	/// 	- with: The view model object
	func configure(with viewModel: SubjectCellViewModel) {
		subjectNameLabel.text = viewModel.name
	}
}
