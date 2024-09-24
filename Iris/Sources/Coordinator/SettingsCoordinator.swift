import UIKit

/// Coordinator which will take care of navigation events related to SettingsVC
final class SettingsCoordinator: Coordinator {

	enum Event {
		case settingsCellTapped(IndexPath)
	}

	var navigationController = UINavigationController()

	private var rootViewController: UIViewController? {
		guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
		return scene.windows.first?.rootViewController
	}

	private let githubURL = "https://github.com/Luki120/"
	private let sourceCodeURL = "https://github.com/Luki120/Iris"

	func eventOccurred(with event: Event) {
		switch event {
			case .settingsCellTapped(let indexPath):
				switch indexPath.section {
					case 0: openURL(URL(string: githubURL))
					case 1:
						switch indexPath.item {
							case 0: deleteAccount()
							case 1:
								UserDefaults.standard.removeObject(forKey: "jwtToken")
								presentLoginVC()
							default: break
						}
					case 2: openURL(URL(string: sourceCodeURL))
					default: break
				}
		}
	}

	private func deleteAccount() {
		Task {
			do {
				let result = try await AuthService.shared.deleteAccount()

				switch result {
					case .success:
						await MainActor.run {
							presentLoginVC()
						}
					case .unauthorized: break
				}
			}
			catch let error as AuthError {
				print(error.description)
			}
		}
	}

	private func openURL(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url)
	}

	private func presentLoginVC() {
		let loginVC = LoginVC()
		loginVC.modalPresentationStyle = .fullScreen
		loginVC.modalTransitionStyle = .crossDissolve

		rootViewController?.dismiss(animated: true)
		rootViewController?.present(loginVC, animated: true)
	}

}
