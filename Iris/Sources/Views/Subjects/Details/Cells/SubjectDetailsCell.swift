//
//  SubjectDetailsCell.swift
//  Iris
//
//  Created by Luki on 20/08/2024.
//

import UIKit

/// UICollectionViewCell to represent the subject details
final class SubjectDetailsCell: UICollectionViewCell {

	private lazy var hashtagLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(withStyle: .medium, size: 20)
		label.text = "#"
		label.textAlignment = .center
		label.backgroundColor = .irisSlateBlue
		label.translatesAutoresizingMaskIntoConstraints = false
		label.layer.cornerRadius = 15
		label.layer.masksToBounds = true
		contentView.addSubview(label)
		return label
	}()

	private lazy var examLabel: UILabel = {
		let label = UILabel()
		label.font = .quicksand(withStyle: .semiBold, size: 18)
		label.textColor = .systemGray
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}()

	private(set) lazy var gradeTextField: UITextField = {
		let textField = UITextField()
		textField.font = .quicksand(withStyle: .semiBold, size: 25)
		textField.delegate = self
		textField.keyboardType = .numberPad
		textField.textAlignment = .center
		textField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(textField)
		return textField
	}()

	var id: String!
	var completion: ((String) -> Void)!

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemGroupedBackground
		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 15

		layoutUI()
	}

	// MARK: - Private

	private func layoutUI() {
		NSLayoutConstraint.activate([
			hashtagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			hashtagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			hashtagLabel.widthAnchor.constraint(equalToConstant: 30),
			hashtagLabel.heightAnchor.constraint(equalToConstant: 30),

			examLabel.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 8),
			examLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			examLabel.leadingAnchor.constraint(equalTo: hashtagLabel.leadingAnchor),

			gradeTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			gradeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			gradeTextField.widthAnchor.constraint(equalToConstant: 30),
			gradeTextField.heightAnchor.constraint(equalToConstant: 30),
		])
	}

}

// MARK: - Public

extension SubjectDetailsCell {
	/// Function to configure the cell with its respective view model
	/// -  Parameters:
	/// 	- with: The view model object
	func configure(with viewModel: SubjectDetailsCellViewModel) {
		examLabel.text = viewModel.exam
	}
}

// MARK: - UITextFieldDelegate

extension SubjectDetailsCell: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let id, let completion else { return }

		UserDefaults.standard.set(textField.text, forKey: id)
		completion(textField.text ?? "")
	}
}
