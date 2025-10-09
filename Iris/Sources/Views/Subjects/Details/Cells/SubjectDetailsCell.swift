//
//  SubjectDetailsCell.swift
//  Iris
//
//  Created by Luki on 20/08/2024.
//

import UIKit

/// `UICollectionViewCell` to represent the subject details
final class SubjectDetailsCell: UICollectionViewCell {
	private var hashtagLabel, examLabel, finalExamLabel: UILabel!
	private var examLabelTopConstraint, examLabelBottomConstraint: NSLayoutConstraint!

	private lazy var gradeTextField: UITextField = {
		let textField = UITextField()
		textField.font = .quicksand(withStyle: .semiBold, size: 25)
		textField.delegate = self
		textField.keyboardType = .numberPad
		textField.textAlignment = .center
		textField.addDoneButton()
		textField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(textField)
		return textField
	}()

	private lazy var finalExamDatePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.alpha = gradeTextField.text == "" ? 0 : 1
		datePicker.datePickerMode = .date
		datePicker.preferredDatePickerStyle = .compact
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
		return datePicker
	}()

#if !targetEnvironment(macCatalyst)
	private var datePickerLabel: UILabel {
		finalExamDatePicker
			.subviews.first?.subviews.first?.subviews.first?.subviews[1].subviews.first as? UILabel ?? UILabel()
	}
#endif

	var onGradeChange: (String) -> Void = { _ in }
	var onSelectedExamDate: (Date) -> Void = { _ in }

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemGroupedBackground
		contentView.layer.cornerCurve = .continuous
		contentView.layer.cornerRadius = 15

		setupUI()
	}

	// MARK: - Private

	private func setupUI() {
		hashtagLabel = createLabel(color: .white, fontStyle: .medium, size: 20, text: "#")
		hashtagLabel.backgroundColor = .irisSlateBlue
		hashtagLabel.layer.cornerRadius = 15
		hashtagLabel.layer.masksToBounds = true

		examLabel = createLabel(size: 18)
		finalExamLabel = createLabel(size: 16, text: "Taken on", addsSubview: false)

		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			hashtagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			hashtagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			hashtagLabel.widthAnchor.constraint(equalToConstant: 30),
			hashtagLabel.heightAnchor.constraint(equalToConstant: 30),

			examLabel.leadingAnchor.constraint(equalTo: hashtagLabel.leadingAnchor),

			gradeTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			gradeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			gradeTextField.widthAnchor.constraint(equalToConstant: 30),
			gradeTextField.heightAnchor.constraint(equalToConstant: 30)
		])

		examLabelTopConstraint = examLabel.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 8)
		examLabelBottomConstraint = examLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)

		examLabelTopConstraint.isActive = true
		examLabelBottomConstraint.isActive = true
	}

	private func setupFinalCell() {
		hashtagLabel.isHidden = true

		[finalExamLabel, finalExamDatePicker].forEach { contentView.addSubviews($0) }
		[examLabelTopConstraint, examLabelBottomConstraint].forEach { $0.isActive = false }

		examLabelTopConstraint = examLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
		examLabelTopConstraint.isActive = true

		NSLayoutConstraint.activate([
			finalExamLabel.topAnchor.constraint(equalTo: examLabel.bottomAnchor, constant: 10),
			finalExamLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			finalExamLabel.leadingAnchor.constraint(equalTo: examLabel.leadingAnchor),

			finalExamDatePicker.leadingAnchor.constraint(equalTo: finalExamLabel.trailingAnchor, constant: 8),
			finalExamDatePicker.centerYAnchor.constraint(equalTo: finalExamLabel.centerYAnchor)
		])

#if !targetEnvironment(macCatalyst)
		datePickerLabel.font = .quicksand(withStyle: .semiBold, size: 12)
#endif
	}

	@objc
	private func didChangeDate(_ sender: UIDatePicker) {
		onSelectedExamDate(sender.date)
	}

	@objc
	private func didChangeGrade(_ sender: UITextField) {
		UIView.animate(withDuration: 0.35) {
			self.finalExamDatePicker.alpha = sender.text == "" ? 0 : 1
		}
	}

	// MARK: - Reusable

	private func createLabel(
		color: UIColor = .systemGray,
		fontStyle: UIFont.QuicksandStyle = .semiBold,
		size: CGFloat,
		text: String = "",
		addsSubview: Bool = true
	) -> UILabel {
		let label = UILabel()
		label.font = .quicksand(withStyle: fontStyle, size: size)
		label.text = text
		label.textColor = color
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		if addsSubview {
			contentView.addSubview(label)
		}
		return label
	}
}

// MARK: - Public

extension SubjectDetailsCell {
	/// Function to configure the cell with its respective view model
	/// -  Parameter with: The view model object
	func configure(with viewModel: SubjectDetailsCellViewModel) {
		examLabel.text = viewModel.exam
		gradeTextField.text = viewModel.displayedGrade

		guard viewModel.isFinalCell else { return }
		finalExamDatePicker.date = viewModel.finalExamDates.first ?? .now
		gradeTextField.addTarget(self, action: #selector(didChangeGrade(_:)), for: .editingChanged)
		setupFinalCell()
	}
}

// MARK: - UITextFieldDelegate

extension SubjectDetailsCell: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		onGradeChange(text)
	}
}

private extension UITextField {
	func addDoneButton() {
		guard keyboardType == .numberPad else { return }

		let toolbar = UIToolbar()
		toolbar.barStyle = .default

		let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButtonItem = UIBarButtonItem(
			title: "Done",
			style: .done,
			target: self,
			action: #selector(didTapDoneButton)
		)
		toolbar.items = [flexibleSpaceItem, doneButtonItem]
		toolbar.sizeToFit()

		inputAccessoryView = toolbar
	}

	@objc
	private func didTapDoneButton() {
		resignFirstResponder()
	}
}
