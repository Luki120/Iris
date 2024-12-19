import UIKit

/// Root view controller, which will show our tabs
final class TabBarVC: UITabBarController {

	private let homeCoordinator = HomeCoordinator()
    private let gradesCoordinator = GradesCoordinator()
	private let pomodoroCoordinator = PomodoroCoordinator()

	// MARK: - Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init() {
		super.init(nibName: nil, bundle: nil)

        viewControllers = [
			homeCoordinator.navigationController,
			gradesCoordinator.navigationController,
			pomodoroCoordinator.navigationController
		]
	}

}
