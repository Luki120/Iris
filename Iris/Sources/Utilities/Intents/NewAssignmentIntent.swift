//
//  NewAssignmentIntent.swift
//  Iris
//
//  Created by Luki on 05/06/2025.
//

import AppIntents
import SwiftData

struct NewAssignmentIntent: AppIntent {
	static let title: LocalizedStringResource = "Create new assignment"
	static let openAppWhenRun = true

	@Parameter(title: "Choose a subject")
	private var subjectEntity: SubjectEntity

	@Parameter(title: "Assignment")
	private var assignment: String

	@MainActor
	func perform() async throws -> some IntentResult {
		let descriptor = FetchDescriptor<Subject>(sortBy: [SortDescriptor(\.name)])

		guard let subjects = try? SubjectsManager.shared.context?.fetch(descriptor) else { return .result() }
		let subject = subjects.first(where: { $0.name == subjectEntity.id })
		subject?.tasks.append(.init(title: assignment, priority: .normal))

		try? SubjectsManager.shared.context?.save()
		return .result()
	}
}

struct AppShortcuts: AppShortcutsProvider {
	@AppShortcutsBuilder
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: NewAssignmentIntent(),
			phrases: ["Use \(.applicationName) to create a new assignment"],
			shortTitle: "Create assignment",
			systemImageName: "book"
		)
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
			return SubjectsManager.shared.currentlyTakingSubjects.map { .init(from: $0) }
		}
	}
}
