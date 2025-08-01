//
//  NewAssignmentIntent.swift
//  Iris
//
//  Created by Luki on 05/06/2025.
//

import AppIntents

/// App intent to create new assignments for a specific subject
struct NewAssignmentIntent: AppIntent {
	static let title: LocalizedStringResource = "Create new assignment"
	static let openAppWhenRun = true

	@Parameter(title: "Choose subject")
	private var subjectEntity: SubjectEntity

	@Parameter(title: "Assignment")
	private var assignment: String

	@MainActor
	func perform() async throws -> some IntentResult {
		let subject = SubjectsManager.shared.currentlyTakingSubjects.first(where: { $0.name == subjectEntity.id })

		let nextSortOrder = subject?.tasks
			.filter { !$0.isCompleted && $0.priority != .exam }
			.map(\.sortOrder)
			.max() ?? -1

		subject?.tasks.append(.init(title: assignment, priority: .normal, sortOrder: nextSortOrder + 1))
		return .result()
	}
}

struct SubjectEntity: AppEntity {
	static let defaultQuery = SubjectEntityQuery()
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Subject"

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: id))
	}

	let id: String

	init(id: String) {
		self.id = id
	}

	init(from subject: Subject) {
		self.id = subject.name
	}

	@MainActor
	struct SubjectEntityQuery: EntityQuery {
		func entities(for identifiers: [SubjectEntity.ID]) async throws -> [SubjectEntity] {
			return identifiers.compactMap { .init(id: $0) }
		}

		func suggestedEntities() async throws -> [SubjectEntity] {
			return SubjectsManager.shared.currentlyTakingSubjects.compactMap { .init(from: $0) }
		}
	}
}
