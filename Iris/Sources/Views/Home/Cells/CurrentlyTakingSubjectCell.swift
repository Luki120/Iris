import UIKit

/// `UICollectionViewCell` subclass to represent the currently taking subject cell
final class CurrentlyTakingSubjectCell: SubjectCell {
	/// Function to configure the cell with its respective view model
	/// -  Parameter with: The view model object
	func configure(with viewModel: CurrentlyTakingSubjectCellViewModel) {
		subjectNameLabel.text = viewModel.name
	}
}
