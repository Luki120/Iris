import Foundation
import SwiftData
import struct SwiftUI.Color

/// API model class that represents a `Subject` object
@Model
final class Subject: @unchecked Sendable {
	private(set) var name: String
	private(set) var year: String
	private(set) var shortName: String
	private(set) var hasThreeExams: Bool

	var examGrades = [Int]()
	var finalGrades = [Int]()
	var isFinished = false
	var finalExamDates = [Date]()

	var tasks = [Task]()

	/// Designated initializer
	///  - Parameters:
	///		- name: A `String` that represents the name
	///		- year: A `String` that represents the year
	///		- shortName: A `String` that represents the short name, useful for displaying in charts
	///		- examGrades: An `[Int]` array to represent the grades, defaults to empty
	///		- finalGrades: An `[Int]` array to represent the final grades, defaults to empty
	///		- isFinished: A `Bool` that represents if I finished the subject, defaults to `false`
	///		- hasThreeExams: A `Bool` that represents wether the subject requires taking three exams or more
	///		- finalExamDate: An array of  `Date` objects that represent the subject's final exam dates, defaults to empty`
	init(
		name: String,
		year: String,
		shortName: String,
		examGrades: [Int] = [],
		finalGrades: [Int] = [],
		isFinished: Bool = false,
		hasThreeExams: Bool,
		finalExamDates: [Date] = []
	) {
		self.name = name
		self.year = year
		self.shortName = shortName
		self.examGrades = examGrades
		self.finalGrades = finalGrades
		self.isFinished = isFinished
		self.hasThreeExams = hasThreeExams
		self.finalExamDates = finalExamDates
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
		///		- priority: A `Priority` enum that represents the assignment's priority
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
		self.init(
			name: subjectDTO.name,
			year: subjectDTO.year,
			shortName: subjectDTO.shortName.isEmpty ? subjectDTO.name : subjectDTO.shortName,
			examGrades: subjectDTO.examGrades,
			finalGrades: subjectDTO.finalGrades,
			isFinished: subjectDTO.isFinished,
			hasThreeExams: subjectDTO.hasThreeExams,
			finalExamDates: subjectDTO.finalExamDates.map { Date.dateFormatter.date(from: $0) ?? .now }
		)
	}
}

extension Subject {
	func setFinalGrade(_ grade: Int) {
		if finalGrades.isEmpty {
			finalGrades.append(grade)
		}
		else {
			finalGrades[0] = grade
		}
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
