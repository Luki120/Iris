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

	private var examsList: [Subject.Task] {
		return subject.tasks.filter { $0.priority == .exam && !$0.isCompleted }
	}

	private var pendingAssignments: [Subject.Task] {
		return subject.tasks.filter { !$0.isCompleted && $0.priority != .exam }.sorted(using: SortDescriptor(\.timestamp))
	}

	private var completedAssignments: [Subject.Task] {
		return subject.tasks.filter { $0.isCompleted }.sorted(using: SortDescriptor(\.timestamp))
	}

	var body: some View {
		VStack(spacing: 0) {
			if subject.tasks.isEmpty {
				ContentUnavailableView {
					Text("There's currently no assignments for this subject")
						.font(.quicksand(withStyle: .medium))
				}
			}
			else {
				List {
					if !examsList.isEmpty {
						ExamsListView(subject: subject)
					}
					if !pendingAssignments.isEmpty {
						PendingAssignmentsView()
					}
					if !completedAssignments.isEmpty {
						CompletedAssignmentsView(subject: subject)
					}
				}
				.scrollIndicators(.hidden)
			}
			Group {
				Button("Add") {
					withAnimation(.snappy) {
						subject.tasks.append(.init(title: "", priority: .normal))
					}
				}
				.foregroundStyle(.primary)
				.frame(width: 120, height: 50)
				.background(Color.irisSlateBlue, in: .capsule)
				.padding(.bottom, 20)
				.shadow(color: .primary.opacity(0.5), radius: 4)
			}
			.frame(maxWidth: .infinity)
			.background(
				subject.tasks.isEmpty ? Color(uiColor: .systemBackground) : Color(uiColor: .systemGroupedBackground)
			)
		}
	}

	@ViewBuilder
	private func ExamsListView(subject: Subject) -> some View {
		Section("Exams") {
			ForEach(examsList) { task in
				SubjectDetailsAssignmentCellView(subject: subject, task: task)
			}
		}
	}

	@ViewBuilder
	private func PendingAssignmentsView() -> some View {
		Section("Pending") {
			ForEach(pendingAssignments) { task in
				SubjectDetailsAssignmentCellView(subject: subject, task: task)
			}
		}
	}
}

/// View that'll show the completed assignments
private struct CompletedAssignmentsView: View {

	let subject: Subject
	@State private var showAll = false

	private var filteredTasks: [Subject.Task] {
		return subject.tasks.filter { $0.isCompleted }.sorted(using: SortDescriptor(\.timestamp))
	}

	var body: some View {
		Section {
			ForEach(filteredTasks.prefix(showAll ? filteredTasks.count : 5)) { task in
				SubjectDetailsAssignmentCellView(subject: subject, task: task)
			}
		} header: {
			HStack {
				Text("Completed")

				Spacer()

				Button("Show recents") {
					withAnimation(.snappy) {
						showAll = false
					}
				}
				.opacity(showAll ? 1 : 0)
				.transition(.opacity)
			}
			.font(.caption)

		} footer: {
			if filteredTasks.count >= 5 && !showAll {
				HStack {
					Text("Showing the 5 most recent assignments")
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
