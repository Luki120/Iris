import UIKit

/// UICollectionViewCell subclass to represent the currently taking subject cell
final class CurrentlyTakingSubjectCell: SubjectCell {

	func configure(with viewModel: CurrentlyTakingSubjectCellViewModel) {
		subjectNameLabel.text = viewModel.name
	}

}
