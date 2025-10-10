import class SwiftUI.UIHostingController
import protocol SwiftUI.View
import UIKit

/// Controller that'll show the grades chart view
final class GradesVC: UIViewController {
	var coordinator: GradesCoordinator?

	private let hostingController: UIHostingController<some View> = UIHostingController(
		rootView: GradesChartView().font(.quicksand())
	)

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		addChild(hostingController)

		view.backgroundColor = .systemBackground
		view.addSubview(hostingController.view)
		view.pinViewToSafeAreas(hostingController.view)
	}
}
