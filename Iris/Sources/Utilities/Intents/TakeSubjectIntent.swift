//
//  TakeSubjectIntent.swift
//  Iris
//
//  Created by Luki on 24/07/2025.
//

import AppIntents

/// App intent to take a new subject
struct TakeSubjectIntent: AppIntent {
	static let title: LocalizedStringResource = "Take new subject"
	static let openAppWhenRun = true

	@Parameter(title: "Choose a subject")
	private var subjectEntity: NewSubjectEntity

	@MainActor
	func perform() async throws -> some IntentResult {
		let subjects = try await NewSubjectEntity.defaultQuery.fetchSubjects()
		guard let subject = subjects.first(where: { $0.name == subjectEntity.id }) else { return .result() }

		SubjectsManager.shared.takeSubject(subject)
		return .result()
	}
}

struct NewSubjectEntity: AppEntity {
	static let defaultQuery = NewSubjectEntityQuery()
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
	struct NewSubjectEntityQuery: EntityQuery {
		func entities(for identifiers: [NewSubjectEntity.ID]) async throws -> [NewSubjectEntity] {
			return identifiers.compactMap { .init(id: $0) }
		}

		func suggestedEntities() async throws -> [NewSubjectEntity] {
			return try await fetchSubjects().map { .init(from: $0) }
		}

		fileprivate func fetchSubjects() async throws -> [Subject] {
			guard let url = URL(string: SubjectsService.Constants.baseURL) else { return [] }
			let subjects = try await SubjectsService.shared.fetchSubjects(withURL: url)

			return subjects.compactMap { .init(from: $0) }
		}
	}
}
