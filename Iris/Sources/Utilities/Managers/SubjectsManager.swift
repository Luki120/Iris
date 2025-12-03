import Foundation
import SwiftData

/// Singleton to handle finished & curently taking subjects
@MainActor
@Observable
final class SubjectsManager {
	private(set) var currentlyTakingSubjects = [Subject]()
	private(set) var passedSubjects = [Subject]()

	private var currentUserId = ""
	private var containerCache = [String:ModelContainer]()

	private var backgroundActor: BackgroundActor!
	private(set) var sharedContainer: ModelContainer!

	static let shared = SubjectsManager()

	private init() {
		Task {
			await loadData()
		}
	}

	private func createContainer(for userId: String) throws -> ModelContainer {
		if let cached = containerCache[userId] {
			return cached
		}

		let schema = Schema([Subject.self, Subject.Task.self])

		let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		let userDirectory = appSupportURL.appendingPathComponent("Users/\(userId)", isDirectory: true)

		try FileManager.default.createDirectory(at: userDirectory, withIntermediateDirectories: true)

		let storeURL = userDirectory.appendingPathComponent("default.store")

		let modelConfiguration = ModelConfiguration(userId, schema: schema, url: storeURL)
		let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

		containerCache[userId] = container
		return container
	}
}

// MARK: - Public

extension SubjectsManager {
	/// Function to load data
	func loadData() async {
		guard let backgroundActor else { return }

		do {
			let allSubjects: [Subject] = try await backgroundActor.fetch()
			currentlyTakingSubjects = allSubjects.filter { !$0.isFinished }
			passedSubjects = allSubjects.filter { $0.isFinished }
		}
		catch {
			print("❌ Error loading user data: \(error.localizedDescription)")
		}
	}

	/// Function to delete user data for a given user
	/// - Parameter userId: A `String` that represents the user id
	func deleteData(userId: String) throws {
		let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		let userDirectory = appSupportURL.appendingPathComponent("Users/\(userId)", isDirectory: true)

		containerCache.removeValue(forKey: userId)
		try FileManager.default.removeItem(at: userDirectory)
	}

	/// Function to track currently taking subjects
	/// - Parameter subject: The `Subject` object
	func takeSubject(_ subject: Subject) {
		Task {
			let subject = Subject(
				name: subject.name,
				year: subject.year,
				shortName: subject.shortName,
				hasThreeExams: subject.hasThreeExams,
			)

			guard !currentlyTakingSubjects.contains(subject) else { return }
			currentlyTakingSubjects.append(subject)

			await backgroundActor.insert(subject)
		}
	}

	/// Function to delete a subject at the given index
	/// - Parameters:
	///		- subject: The `Subject` object
	///		- index: An `Int` that represents the index
	///		- isPassed: A `Bool` to check wether it's a passed subject, defaults to `false`
	func delete(subject: Subject, at index: Int, isPassed: Bool = false) {
		Task {
			if isPassed {
				passedSubjects.remove(at: index)
			}
			else {
				currentlyTakingSubjects.remove(at: index)
			}

			await backgroundActor.delete(subject)
		}
	}

	/// Function to mark a subject as passed at the given index
	/// - Parameters:
	///		- subject: The `Subject` object
	///		- index: An `Int` that represents the index
	func passed(subject: Subject, at index: Int) {
		Task {
			subject.isFinished = true
			delete(subject: subject, at: index)
			await backgroundActor.save()

			try await Task.sleep(for: .seconds(0.2))

			guard !passedSubjects.contains(subject) else { return }
			passedSubjects.append(subject)
			await backgroundActor.insert(subject)
		}
	}

	/// Function to update the currently taking subjects array
	/// - Parameter subject: The `Subject` object
	func update(subject: Subject) {
		guard let index = currentlyTakingSubjects.firstIndex(where: { $0 === subject }) else { return }
		currentlyTakingSubjects[index] = subject
	}
}

// MARK: - User

extension SubjectsManager {
	/// Function to set the current user
	/// - Parameter id: A `String` that represents the user id
	func setCurrentUser(id: String) async {
		guard currentUserId != id else { return }

		do {
			currentUserId = id

			let container = try createContainer(for: id)
			sharedContainer = container
			backgroundActor = BackgroundActor(modelContainer: container)

			await loadData()
		}
		catch {
			print("❌ Error setting up container for user \(id): \(error.localizedDescription)")
		}
	}

	/// Function to clear data for the current user
	func clearCurrentUser() {
		currentUserId = ""

		if !currentlyTakingSubjects.isEmpty {
			currentlyTakingSubjects.removeAll()
		}

		backgroundActor = nil
		sharedContainer = nil
	}
}

// MARK: - SwiftData

extension SubjectsManager {
	/// Function to save data to the persistent storage
	func save() {
		Task {
			await backgroundActor.save()
		}
	}

	/// Function to delete a SwiftData model from the database
	/// - Parameter model: The `PersistentModel` object
	func delete<M: PersistentModel>(_ model: M) {
		Task { [model] in
			await backgroundActor.delete(model)
		}
	}

	/// Function to purge all data from the SwiftData container, for development purposes
	func purgeAllData() {
		Task {
			try await backgroundActor.purgeAllData(for: Subject.self)
			try await backgroundActor.purgeAllData(for: Subject.Task.self)
			exit(0)
		}
	}
}

private extension SubjectsManager {
	final actor BackgroundActor {
		let modelContainer: ModelContainer
		private let modelExecutor: ModelExecutor
		private var modelContext: ModelContext { modelExecutor.modelContext }

		init(modelContainer: ModelContainer) {
			self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
			self.modelExecutor.modelContext.autosaveEnabled = true
			self.modelContainer = modelContainer
		}

		func insert<M: PersistentModel>(_ model: M) {
			modelContext.insert(model)
			save()
		}

		func delete<M: PersistentModel>(_ model: M) {
			modelContext.delete(model)
		}

		func fetch<M: PersistentModel>() throws -> [M] {
			let descriptor = FetchDescriptor<M>()
			return try modelContext.fetch(descriptor)
		}

		func purgeAllData<M: PersistentModel>(for model: M.Type) throws {
			if #available(iOS 18, *) {
				try modelContainer.erase()
			}
			else {
				try modelContext.delete(model: model.self)
			}
		}

		func save() {
			do {
				guard modelContext.hasChanges else { return }
				try modelContext.save()
			}
			catch {
				print("❌ Error saving model: \(error.localizedDescription)")
			}
		}
	}
}

extension Thread {
	static var isMain: Bool { isMainThread }
}
