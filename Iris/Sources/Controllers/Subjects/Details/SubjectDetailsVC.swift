//
//  SubjectDetailsVC.swift
//  Iris
//
//  Created by Luki on 20/08/2024.
//

import UIKit

/// Controller that'll show the subjects view
final class SubjectDetailsVC: UIViewController {

	private let subjectDetailsViewViewModel: SubjectDetailsViewViewModel
	private let subjectDetailsView: SubjectDetailsView

	var coordinator: HomeCoordinator?

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		fatalError()
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this vc's view
	init(viewModel: SubjectDetailsViewViewModel) {
		self.subjectDetailsViewViewModel = viewModel
		self.subjectDetailsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		title = subjectDetailsViewViewModel.title

		view.backgroundColor = .systemBackground
		view.addSubview(subjectDetailsView)
		view.pinViewToSafeAreas(subjectDetailsView)

		subjectDetailsView.delegate = self
	}

}

// MARK: - SubjectDetailsViewDelegate

extension SubjectDetailsVC: SubjectDetailsViewDelegate {
	func subjectDetailsView(_ subjectDetailsView: SubjectDetailsView, didTapAssignmentsCell subject: Subject) {
		coordinator?.eventOccurred(with: .subjectDetailsAssignmentsCellTapped(subject: subject))
	}
}
