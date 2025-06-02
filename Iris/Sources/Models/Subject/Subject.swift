import Foundation
import SwiftData
import struct SwiftUI.Color

/// API model class that represents a Subject object
@Model
final class Subject: Codable {
	private(set) var name: String
	private(set) var year: String

	var grades = [Int]()
	var isFinished = false
	var hasThreeExams = false
	var finalExamDate = Date()

	var tasks = [Task]()

	/// Designated initializer
	///  - Parameters:
	///		- name: A string that represents the name
	///		- year: A string that represents the year
	///		- grades: An array of integers to represent the grades, defaults to empty
	///		- isFinished: A boolean that represents if I finished the subject, defaults to`false`
	///		- hasThreeExams: A boolean that represents wether the subject requires taking three exams or more, defaults to`false`
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

	// MARK: - Codable

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		name = try container.decode(String.self, forKey: .name)
		year = try container.decode(String.self, forKey: .year)
		grades = try container.decode([Int].self, forKey: .grades)
		isFinished = try container.decode(Bool.self, forKey: .isFinished)
		hasThreeExams = try container.decode(Bool.self, forKey: .hasThreeExams)

		let dateString = try container.decode(String.self, forKey: .finalExamDate)

		guard let finalExamDate = Date.dateFormatter.date(from: dateString) else { return }
		self.finalExamDate = finalExamDate
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(name, forKey: .name)
		try container.encode(year, forKey: .year)
		try container.encode(grades, forKey: .grades)
		try container.encode(isFinished, forKey: .isFinished)
		try container.encode(hasThreeExams, forKey: .hasThreeExams)
		try container.encode(finalExamDate, forKey: .finalExamDate)
	}

	private enum CodingKeys: String, CodingKey {
		case name, year, grades, isFinished, hasThreeExams, finalExamDate
	}
}

extension Subject {
	/// Class that represents a subject's assignment
	@Model
	final class Task {
		var title: String
		var priority: Priority = Priority.normal

		var examDate = Date()
		var isCompleted = false
		private(set) var timestamp = Date()

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
		///		- title: A string that represents the assignment's title
		///		- priority: An enum that represents the assignment's priority
		init(title: String, priority: Priority) {
			self.title = title
			self.priority = priority
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

private extension Date {
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()
}
