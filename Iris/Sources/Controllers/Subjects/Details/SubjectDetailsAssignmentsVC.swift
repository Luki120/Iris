//
//  SubjectDetailsTasksVC.swift
//  Iris
//
//  Created by Luki on 09/09/2024.
//

import class SwiftUI.UIHostingController
import protocol SwiftUI.View
import UIKit

/// Controller that'll show the subject's assignments view
final class SubjectDetailsAssignmentsVC: UIViewController {
	private let viewModel: SubjectDetailsAssignmentsViewViewModel

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		fatalError()
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this vc's view
	init(viewModel: SubjectDetailsAssignmentsViewViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)

		guard let container = SubjectsManager.shared.sharedContainer else { return }

		let subjectDetailsAssignmentsView = SubjectDetailsAssignmentsView(subject: viewModel.subject)
			.modelContext(.init(container))

		let hostingController = UIHostingController(rootView: subjectDetailsAssignmentsView)

		addChild(hostingController)
		view.addSubview(hostingController.view)
		view.pinViewToSafeAreas(hostingController.view)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Assignments"
		view.backgroundColor = .systemBackground
	}
}
