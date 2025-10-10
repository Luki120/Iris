//
//  AllGradesView.swift
//  Iris
//
//  Created by Luki on 04/10/2025.
//

import SwiftUI

/// All grades view
struct AllGradesView: View {
	let subjects: [Subject]
	let subjectManager: SubjectsManager

	@State private var grade = ""
	@State private var finalDate = ""
	@State private var showAlert = false

	private struct GradeEntry: Identifiable {
		let id = UUID()
		let date: Date
		let grade: Int
	}

	var body: some View {
		List(subjects) { subject in
			NavigationLink(subject.name) {
				GradesView(subject: subject)
			}
			.swipeActions(edge: .trailing) {
				Button("", systemImage: "trash", role: .destructive) {
					guard let index = subjects.firstIndex(where: { $0 === subject }) else { return }
					subjectManager.delete(subject: subject, at: index, isPassed: true)
				}
			}
		}
		.navigationTitle("Finals")
	}

	@ViewBuilder
	private func GradesView(subject: Subject) -> some View {
		let gradeEntries = zip(subject.finalExamDates, subject.finalGrades).map { date, grade in
			GradeEntry(date: date, grade: grade)
		}

		List(gradeEntries.sorted(using: SortDescriptor(\.date))) { entry in
			HStack {
				let date = AllGradesView.dateFormatter.string(from: entry.date)
				Text("Final \(date)")

				Spacer()

				Text("Grade: \(entry.grade)")
					.padding(10)
					.background {
						RoundedRectangle(cornerRadius: 10, style: .continuous)
							.fill(entry.grade >= 4 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
					}
			}
			.font(.quicksand())
			.swipeActions(edge: .trailing) {
				Button("", systemImage: "trash", role: .destructive) {
					if let index = subject.finalGrades.firstIndex(of: entry.grade),
					   index < subject.finalExamDates.count,
					   subject.finalExamDates[index] == entry.date {
						subject.finalGrades.remove(at: index)
						subject.finalExamDates.remove(at: index)
					}
				}
			}
		}
		.alert("Add new grade", isPresented: $showAlert) {
			Group {
				TextField("Final date: 17/7/25", text: $finalDate)
				TextField("Grade:", text: $grade)
					.keyboardType(.numberPad)
			}
			.font(.subheadline)

			Button("Add") {
				guard let date = AllGradesView.dateFormatter.date(from: finalDate) else { return }

				subject.finalExamDates.append(date)
				subject.finalGrades.append(Int(grade) ?? 0)
				subjectManager.save()
			}

			Button("Cancel", role: .cancel) {}
		}
		.animation(.snappy, value: subject.finalGrades)
		.navigationTitle(subject.name)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("", systemImage: "plus") {
					showAlert.toggle()
				}
			}
		}
	}

	private
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d/M/yy"
		return formatter
	}()
}
