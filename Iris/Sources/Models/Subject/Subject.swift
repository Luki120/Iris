import Foundation
import SwiftData
import struct SwiftUI.Color

/// API model class that represents a `Subject` object
@Model
final class Subject {
	private(set) var name: String
	private(set) var year: String

	var grades = [Int]()
	var isFinished = false
	var hasThreeExams = false
	var finalExamDate = Date()

	var tasks = [Task]()

	/// Designated initializer
	///  - Parameters:
	///		- name: A `String` that represents the name
	///		- year: A `String` that represents the year
	///		- grades: An `[Int]` array to represent the grades, defaults to empty
	///		- isFinished: A `Bool` that represents if I finished the subject, defaults to `false`
	///		- hasThreeExams: A `Bool` that represents wether the subject requires taking three exams or more, defaults to `false`
	///		- finalExamDate: A `Date` object that represents the subject's final exam date, defaults to `.now`
	init(
		name: String,
		year: String,
		grades: [Int] = [],
		isFinished: Bool = false,
		hasThreeExams: Bool = false,
		finalExamDate: Date = .now
	) {
		self.name = name
		self.year = year
		self.grades = grades
		self.isFinished = isFinished
		self.hasThreeExams = hasThreeExams
		self.finalExamDate = finalExamDate
	}
}

extension Subject {
	/// Class that represents a subject's assignment
	@Model
	final class Task {
		var title: String
		var priority: Priority = Priority.normal
		var sortOrder: Int = 0

		var examDate = Date()
		var isCompleted = false

		@Transient
		enum Priority: String, CaseIterable, Codable {
			case normal = "Normal"
			case exam = "Exam"

			var color: Color {
				switch self {
					case .normal: return .green
					case .exam: return .red
				}
			}
		}

		/// Designated initializer
		///  - Parameters:
		///		- title: A `String` that represents the assignment's title
		///		- priority: A `Priority` object that represents the assignment's priority
		///		- sortOrder: An `Int` that represents the sort order
		init(title: String, priority: Priority, sortOrder: Int) {
			self.title = title
			self.priority = priority
			self.sortOrder = sortOrder
		}
	}
}

extension Subject {
	convenience init(from subjectDTO: SubjectDTO) {
		let parsedDate = Date.dateFormatter.date(from: subjectDTO.finalExamDate) ?? .now

		self.init(
			name: subjectDTO.name,
			year: subjectDTO.year,
			grades: subjectDTO.grades,
			isFinished: subjectDTO.isFinished,
			hasThreeExams: subjectDTO.hasThreeExams,
			finalExamDate: parsedDate
		)
	}
}

// MARK: - Hashable

extension Subject: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}

	static func == (lhs: Subject, rhs: Subject) -> Bool {
		lhs.name == rhs.name
	}
}

// MARK: - Private

private extension Date {
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}
