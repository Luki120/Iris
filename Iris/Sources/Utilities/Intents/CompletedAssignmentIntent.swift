//
//  CompletedAssignmentIntent.swift
//  Iris
//
//  Created by Luki on 24/07/2025.
//

import AppIntents

/// App intent to mark a subject's assignment as completed
struct CompletedAssignmentIntent: AppIntent {
	static let title: LocalizedStringResource = "Complete assignment"
	static let openAppWhenRun = true

	@Parameter(title: "Choose a subject")
	var subjectEntity: SubjectEntity

	@Parameter(title: "Choose a task")
	var assignmentEntity: AssignmentEntity

	@MainActor
	func perform() async throws -> some IntentResult & ProvidesDialog {
		let subjects = SubjectsManager.shared.currentlyTakingSubjects

		guard let subject = subjects.first(where: { $0.name == subjectEntity.id }) else {
			return .result(dialog: "No subject found")
		}
		guard let task = subject.tasks.first(where: { $0.title == assignmentEntity.id }) else {
			return .result(dialog: "No assignment found")
		}

		task.isCompleted = true
		return .result(dialog: "Task \(task.title) marked as completed!")
	}
}

struct AssignmentEntity: AppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Assignment"
	static let defaultQuery = AssignmentEntityQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: id))
	}

	let id: String

	init(id: String) {
		self.id = id
	}

	init(from task: Subject.Task) {
		self.id = task.title
	}

	@MainActor
	struct AssignmentEntityQuery: EntityQuery {
		@IntentParameterDependency<CompletedAssignmentIntent>(\.$subjectEntity)
		private var subjectDependency

		func entities(for identifiers: [AssignmentEntity.ID]) async throws -> [AssignmentEntity] {
			return identifiers.compactMap { .init(id: $0) }
		}

		func suggestedEntities() async throws -> [AssignmentEntity] {
			let subjects = SubjectsManager.shared.currentlyTakingSubjects

			guard let subject = subjects.first(where: { $0.name == subjectDependency?.subjectEntity.id }) else {
				return []
			}

			return subject.tasks
				.filter { !$0.isCompleted }
				.compactMap { AssignmentEntity(from: $0) }
		}
	}
}
