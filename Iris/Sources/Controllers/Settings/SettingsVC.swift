import UIKit

/// Controller that'll show the settings view
final class SettingsVC: UIViewController {

	private let settingsView = SettingsView()

	var coordinator: SettingsCoordinator?

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		settingsView.delegate = self
		settingsView.backgroundColor = .systemBackground

		view.backgroundColor = .systemBackground
		view.addSubview(settingsView)
		view.pinViewToAllEdges(settingsView)
	}

}

// MARK: - SettingsViewDelegate

extension SettingsVC: SettingsViewDelegate {
	func settingsView(_ settingsView: SettingsView, didTapCellAt indexPath: IndexPath) {
		coordinator?.eventOccurred(with: .settingsCellTapped(indexPath))
	}
}
