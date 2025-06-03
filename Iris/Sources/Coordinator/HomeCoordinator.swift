import UIKit

/// Coordinator which will take care of navigation events related to `HomeVC`
final class HomeCoordinator: Coordinator {
	enum Event {
		case allSubjectsCellTapped
		case currentlyTakingSubjectCellTapped(subject: Subject)
		case subjectDetailsAssignmentsCellTapped(subject: Subject)
		case profilePictureButtonTapped
	}

	var navigationController = UINavigationController()

	private let subjectsVC = SubjectsVC()
	private var settingsVC: SettingsVC!

	init() {
		let homeVC = HomeVC()
		homeVC.title = "Home"
		homeVC.coordinator = self
		homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(resource: .home), tag: 0)

		navigationController.viewControllers = [homeVC]
		initSettingsVC()
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .allSubjectsCellTapped: navigationController.pushViewController(subjectsVC, animated: true)

			case .currentlyTakingSubjectCellTapped(let subject):
				let viewModel = SubjectDetailsViewViewModel(subject: subject)
				let subjectDetailsVC = SubjectDetailsVC(viewModel: viewModel)
				subjectDetailsVC.coordinator = self
				navigationController.pushViewController(subjectDetailsVC, animated: true)

			case .subjectDetailsAssignmentsCellTapped(let subject):
				let viewModel = SubjectDetailsAssignmentsViewViewModel(subject: subject)
				let subjectDetailsAssignmentsVC = SubjectDetailsAssignmentsVC(viewModel: viewModel)
				navigationController.pushViewController(subjectDetailsAssignmentsVC, animated: true)

			case .profilePictureButtonTapped:
				let navVC = UINavigationController(rootViewController: settingsVC)
				navigationController.present(navVC, animated: true)
		}
	}
	private func initSettingsVC() {
		settingsVC = SettingsVC()
		settingsVC.title = "Settings"

		let settingsCoordinator = SettingsCoordinator()
		settingsVC.coordinator = settingsCoordinator
	}
}
