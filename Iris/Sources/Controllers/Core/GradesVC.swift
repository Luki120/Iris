import class SwiftUI.UIHostingController
import UIKit

/// Controller that'll show the grades chart view
final class GradesVC: UIViewController {
	var coordinator: GradesCoordinator?

	private let hostingController = UIHostingController(rootView: GradesChartView())

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		addChild(hostingController)

		view.backgroundColor = .systemBackground
		view.addSubview(hostingController.view)
		view.pinViewToSafeAreas(hostingController.view)
	}
}
