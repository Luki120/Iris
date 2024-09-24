import UIKit

/// UICollectionViewCell subclass to represent the subject cell
class SubjectCell: UICollectionViewCell {

	static var identifier: String { String(describing: self) }

	private(set) lazy var subjectNameLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(withStyle: .bold)
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 15
	}

	// ! Private

	private func setupUI() {
		contentView.backgroundColor = .secondarySystemGroupedBackground
		layoutUI()
	}

	private func layoutUI() {
		subjectNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		subjectNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		subjectNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}

}

extension SubjectCell {

	func configure(with viewModel: SubjectCellViewModel) {
		subjectNameLabel.text = viewModel.name
	}

}
