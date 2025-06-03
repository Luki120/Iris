import Foundation

/// View model struct for `CurrentlyTakingSubjectCell`
struct CurrentlyTakingSubjectCellViewModel: Hashable {
	let name: String

	/// Designated initializer
	/// - Parameters:
	///		- model: The `Subject` model object
	init(_ model: Subject) {
		self.name = model.name
	}
}
