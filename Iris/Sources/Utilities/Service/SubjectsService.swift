import Combine
import Foundation

/// Singleton service to make API calls
final class SubjectsService {

	static let shared = SubjectsService()
	private init() {}

	private var apiCache = [String:Data]()

	/// Enum to represent useful constant values
	enum Constants {
		static let baseURL = "https://ianthea-luki120.koyeb.app/v1/subjects"
	}

	/// Function to make API calls
	/// - Parameters:
	///		- withURL: The API call url
	/// - Returns: An array of subjects
	func fetchSubjects(withURL url: URL) async throws -> [Subject] {
		if let cachedData = apiCache[url.absoluteString] {
			return try JSONDecoder().decode([Subject].self, from: cachedData)
		}

		let (data, _) = try await URLSession.shared.data(from: url)
		apiCache[url.absoluteString] = data

		return try JSONDecoder().decode([Subject].self, from: data)
	}
}
