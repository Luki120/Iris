import UIKit

/// Root view controller, which will show our tabs
final class TabBarVC: UITabBarController {

	private let homeCoordinator = HomeCoordinator()
    private let gradesCoordinator = GradesCoordinator()
	private let settingsCoordinator = SettingsCoordinator()

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        viewControllers = [homeCoordinator.navigationController, gradesCoordinator.navigationController]
	}

}
