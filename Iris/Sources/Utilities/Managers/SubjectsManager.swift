import Foundation
import SwiftData

/// Singleton to handle finished & curently taking subjects
@Observable
final class SubjectsManager {

	private(set) var context: ModelContext?
	private(set) var currentlyTakingSubjects = [Subject]()
	private(set) var passedSubjects = [Subject]()
	private(set) var sharedContainer: ModelContainer?

	static let shared = SubjectsManager()

	private init() {
		guard let sharedContainer = try? ModelContainer(for: Subject.self, Subject.Task.self) else { return }
		context = ModelContext(sharedContainer)

		self.sharedContainer = sharedContainer

		let descriptor = FetchDescriptor<Subject>(sortBy: [SortDescriptor(\.name)])
		guard let subjects = try? context?.fetch(descriptor) else { return }

		(currentlyTakingSubjects, passedSubjects) = subjects.reduce(into: ([], [])) {
			if $1.isFinished {
				$0.1.append($1)
			}
			else {
				$0.0.append($1)
			}

			let finalExamKey = $1.name.lowercased().components(separatedBy: .whitespaces).joined() + "FinalExamGrade"
			let finalExamDateKey = $1.name.lowercased().components(separatedBy: .whitespaces).joined() + "FinalExamDate"

			if UserDefaults.standard.object(forKey: finalExamKey) != nil {
				$1.grade = UserDefaults.standard.integer(forKey: finalExamKey)
			}

			if UserDefaults.standard.object(forKey: finalExamDateKey) != nil {
				$1.finalExamDate = UserDefaults.standard.object(forKey: finalExamDateKey) as? Date ?? .now
			}
		}
	}
}

extension SubjectsManager {

	// MARK: - Public

	/// Function to track currently taking subjects
	/// - Parameters:
	///		- subject: The subject object
	func takeSubject(_ subject: Subject) {
		let subject = Subject(
			name: subject.name,
			year: subject.year,
			grade: subject.grade,
			isFinished: subject.isFinished,
			hasThreeExams: subject.hasThreeExams,
			finalExamDate: subject.finalExamDate
		)

		guard !currentlyTakingSubjects.contains(subject) else { return }

		currentlyTakingSubjects.append(subject)
		currentlyTakingSubjects.sort(using: SortDescriptor(\.name))
		context?.insert(subject)
	}

	/// Function to delete a subject at the given index
	/// - Parameters:
	///		- subject: The subject object
	///		- index: The index for the subject
	func delete(subject: Subject, at index: Int, markAsPassed: Bool = false) {
		if !markAsPassed {
			let keys = ["First", "Second", "Third", "Final"]
			keys.forEach {
				let key = subject.name.lowercased().components(separatedBy: .whitespaces).joined() + "\($0)ExamGrade"
				UserDefaults.standard.removeObject(forKey: key)
			}
		}

		currentlyTakingSubjects.remove(at: index)
		context?.delete(subject)
		try? context?.save()
	}

	/// Function to mark a subject as passed at the given index
	/// - Parameters:
	///		- subject: The subject object
	///		- index: The index for the subject
	func markSubjectAsPassed(_ subject: Subject, at index: Int) {
		delete(subject: subject, at: index, markAsPassed: true)

		guard !passedSubjects.contains(subject) else { return }

		passedSubjects.append(subject)
		passedSubjects.sort(using: SortDescriptor(\.name))
		context?.insert(subject)
	}

}
