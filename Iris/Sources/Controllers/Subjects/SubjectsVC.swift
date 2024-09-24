import UIKit

/// Controller that'll show the subjects view
final class SubjectsVC: UIViewController {

	private let subjectsView = SubjectsView()

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Subjects"

		view.backgroundColor = .systemBackground
		view.addSubview(subjectsView)
		view.pinViewToSafeAreas(subjectsView)
	}

}
