import Foundation
import SwiftData

/// Singleton to handle finished & curently taking subjects
@MainActor
@Observable
final class SubjectsManager {
	private(set) var currentlyTakingSubjects = [Subject]()
	private(set) var passedSubjects = [Subject]()

	@ObservationIgnored
	private var backgroundActor: BackgroundActor!

	@ObservationIgnored var sharedContainer: ModelContainer {
		guard let container = try? ModelContainer(for: Subject.self, Subject.Task.self) else {
			fatalError("Failed to initialize a model container")
		}
		return container
	}

	static let shared = SubjectsManager()

	private init() {
		Task {
			self.backgroundActor = .init(modelContainer: sharedContainer)
			let subjects: [Subject] = try await backgroundActor.fetch()

			currentlyTakingSubjects = subjects.filter { !$0.isFinished }
			passedSubjects = subjects.filter { $0.isFinished }
		}
	}
}

// MARK: - Public

extension SubjectsManager {
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
	///		- index: The index for the subject
	func delete(subject: Subject, at index: Int) {
		Task {
			currentlyTakingSubjects.remove(at: index)
			await backgroundActor.delete(subject)
		}
	}

	/// Function to mark a subject as passed at the given index
	/// - Parameters:
	///		- subject: The `Subject` object
	///		- index: The index for the subject
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

// MARK: - SwiftData

extension SubjectsManager {
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
