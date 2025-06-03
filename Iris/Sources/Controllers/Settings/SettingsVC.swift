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

#if targetEnvironment(macCatalyst)
		navigationItem.rightBarButtonItem = .init(
			systemItem: .close,
			primaryAction: UIAction { _ in
				self.coordinator?.eventOccurred(with: .closeButtonTapped)
			}
		)
#endif
	}
}

// MARK: - SettingsViewDelegate

extension SettingsVC: SettingsViewDelegate {
	func settingsView(_ settingsView: SettingsView, didTapCellAt indexPath: IndexPath) {
		coordinator?.eventOccurred(with: .settingsCellTapped(indexPath))
	}
}
