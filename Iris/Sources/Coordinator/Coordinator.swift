import UIKit.UINavigationController

/// Coordinator protocol to which coordinator classes will conform
@MainActor
protocol Coordinator {
	/// Enum to represent the possible navigation events each coordinator will handle
	associatedtype Event
	/// Navigation controller instance used for either presenting, push or pop a view controller
	var navigationController: UINavigationController { get set }
	/// Function that'll handle the specific event
	/// - Parameter event: The type of `Event`
	func eventOccurred(with event: Event)
}
