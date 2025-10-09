import UIKit
import struct SwiftUI.Color
import struct SwiftUI.Font

// MARK: - Foundation

extension String {
	static let githubImageURL = "https://avatars.githubusercontent.com/u/74214115?v=4"
}

extension Notification.Name {
	static let didStartNewTimerNotification = Notification.Name("didStartNewTimerNotification")
}

// MARK: - SwiftUI

extension Color {
	static let irisSlateBlue = Color(uiColor: .irisSlateBlue)
}

extension Font {
	static func quicksand(withStyle style: UIFont.QuicksandStyle, size: CGFloat = 16) -> Font {
		return .custom(style.rawValue, size: size)
	}
}

// MARK: - UIKit

extension UIApplication {
	@MainActor
	func openURL(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url)
	}
}

extension UIColor {
	static let irisSlateBlue = UIColor(red: 0.53, green: 0.37, blue: 1.0, alpha: 1.0)
}

extension UIFont {
	enum QuicksandStyle: String {
		case medium = "Quicksand Medium"
		case semiBold = "Quicksand SemiBold"
		case bold = "Quicksand Bold"
	}
	
	static func quicksand(withStyle style: QuicksandStyle, size: CGFloat = 16) -> UIFont {
		self.init(name: style.rawValue, size: size)!
	}
	
	static func quicksand(style: QuicksandStyle = .medium, size: CGFloat = 16) -> UIFont {
		let font = self.init(name: style.rawValue, size: size) ?? .systemFont(ofSize: size)
		return UIFontMetrics.default.scaledFont(for: font)
	}
}

extension UIView {
	func addSubviews(_ views: UIView...) {
		views.forEach { addSubview($0) }
	}
	
	func pinViewToAllEdges(
		_ view: UIView,
		topConstant: CGFloat = 0,
		bottomConstant: CGFloat = 0,
		leadingConstant: CGFloat = 0,
		trailingConstant: CGFloat = 0
	) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant),
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant)
		])
	}
	
	func pinViewToSafeAreas(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
		])
	}
}
