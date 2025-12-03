import UIKit

/// Controller that'll show the home view
final class HomeVC: UIViewController {
	var coordinator: HomeCoordinator?

	private let homeView = HomeView()

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		homeView.delegate = self
	}

	// MARK: - Private

	private func setupUI() {
		navigationItem.titleView = homeView.titleLabel

		if homeView.nickname == "Luki" {
			navigationItem.rightBarButtonItem = .init(customView: homeView.profilePictureButton)
		}
		else {
			navigationItem.rightBarButtonItem = .init(
				image: .init(.gear),
				style: .plain,
				target: self,
				action: #selector(didTapSettingsButton)
			)
		}

		view.backgroundColor = .systemBackground
		view.addSubview(homeView)
		view.pinViewToSafeAreas(homeView)
	}

	@objc
	private func didTapSettingsButton() {
		coordinator?.eventOccurred(with: .profilePictureButtonTapped)
	}
}

// MARK: - HomeViewDelegate

extension HomeVC: HomeViewDelegate {
	func didTapAllSubjectsCell(in: HomeView) {
		coordinator?.eventOccurred(with: .allSubjectsCellTapped)
	}

	func didTapProfilePictureButton(in: HomeView) {
		coordinator?.eventOccurred(with: .profilePictureButtonTapped)
	}

	func homeView(_ homeView: HomeView, didTap subject: Subject) {
		coordinator?.eventOccurred(with: .currentlyTakingSubjectCellTapped(subject: subject))
	}
}

#Preview {
	TabBarVC()
}
