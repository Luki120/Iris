//
//  SubjectDetailsTasksView.swift
//  Iris
//
//  Created by Luki on 09/09/2024.
//

import SwiftData
import SwiftUI

/// View that'll show the subject's assignments
struct SubjectDetailsAssignmentsView: View {

	let subject: Subject

	var body: some View {
		if subject.tasks.isEmpty {
			ContentUnavailableView {
				Text("There's currently no assignments for this subject")
					.font(.quicksand(withStyle: .medium))
			}
		}
		else {
			List {
				if !subject.tasks.filter({ $0.priority == .exam && !$0.isCompleted }).isEmpty {
					ExamsListView(subject: subject)
				}
				Section("Pending") {
					ForEach(subject.tasks.filter { !$0.isCompleted && $0.priority != .exam }.sorted(using: SortDescriptor(\.timestamp))) { task in
						SubjectDetailsAssignmentCellView(subject: subject, task: task)
					}
				}
				if !subject.tasks.filter({ $0.isCompleted }).sorted(using: SortDescriptor(\.timestamp)).isEmpty {
					CompletedAssignmentsView(subject: subject)
				}
			}
		}

		Button("Add") {
			let task = Subject.Task(title: "", priority: .normal)
			withAnimation(.snappy) {
				subject.tasks.append(task)
			}
		}
		.foregroundStyle(.primary)
		.frame(width: 120, height: 50)
		.background(Color.irisSlateBlue, in: .capsule)
		.padding(.bottom, 20)
		.shadow(color: .primary.opacity(0.5), radius: 4)
	}

	@ViewBuilder
	private func ExamsListView(subject: Subject) -> some View {
		Section("Exams") {
			ForEach(subject.tasks.filter { $0.priority == .exam }) { task in
				SubjectDetailsAssignmentCellView(subject: subject, task: task)
			}
		}
	}
}

/// View that'll show the completed assignments
private struct CompletedAssignmentsView: View {

	@Bindable private(set) var subject: Subject
	@State private var showAll = false

	private var filteredTasks: [Subject.Task] {
		return subject.tasks.filter { $0.isCompleted }.sorted(using: SortDescriptor(\.timestamp))
	}

	var body: some View {
		Section {
			ForEach(filteredTasks.prefix(showAll ? filteredTasks.count : 4)) { task in
				SubjectDetailsAssignmentCellView(subject: subject, task: task)
			}
		} header: {
			HStack {
				Text("Completed")

				Spacer()

				if showAll {
					Button("Show recents") {
						withAnimation(.snappy) {
							showAll = false
						}
					}
				}
			}
			.font(.caption)

		} footer: {
			if filteredTasks.count >= 4 && !showAll {
				HStack {
					Text("Showing the 10 most recent tasks")
						.foregroundStyle(.gray)

					Spacer()

					Button("Show all") {
						withAnimation(.snappy) {
							showAll = true
						}
					}
				}
				.font(.caption)
			}
		}
	}
}
