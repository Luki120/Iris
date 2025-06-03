import Foundation

/// Actor to make API calls
final actor SubjectsService {
	static let shared = SubjectsService()
	private init() {}

	private var apiCache = [String:Data]()

	/// Enum to represent useful constant values
	enum Constants {
		static let baseURL = "https://ianthea-luki120.koyeb.app/v1/subjects"
	}

	/// Function to make API calls
	/// - Parameter url: The API call url
	/// - Returns: `[SubjectDTO]`
	func fetchSubjects(withURL url: URL) async throws -> [SubjectDTO] {
		if let cachedData = apiCache[url.absoluteString] {
			return try JSONDecoder().decode([SubjectDTO].self, from: cachedData)
		}

		let (data, _) = try await URLSession.shared.data(from: url)
		apiCache[url.absoluteString] = data

		return try JSONDecoder().decode([SubjectDTO].self, from: data)
	}
}
