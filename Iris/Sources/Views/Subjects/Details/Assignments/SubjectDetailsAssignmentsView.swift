//
//  SubjectDetailsTasksView.swift
//  Iris
//
//  Created by Luki on 09/09/2024.
//

import SwiftUI

/// View that'll show the subject's assignments
struct SubjectDetailsAssignmentsView: View {
	let subject: Subject

	private var examsList: [Subject.Task] {
		return subject.tasks.filter { $0.priority == .exam && !$0.isCompleted }
	}

	private var pendingAssignments: [Subject.Task] {
		return subject.tasks
			.filter { !$0.isCompleted && $0.priority != .exam }
			.sorted(using: SortDescriptor(\.sortOrder))
	}

	private var completedAssignments: [Subject.Task] {
		return subject.tasks.filter { $0.isCompleted }.sorted(using: SortDescriptor(\.sortOrder))
	}

	var body: some View {
		VStack(spacing: 0) {
			if subject.tasks.isEmpty {
				ContentUnavailableView {
					Text("There's currently no assignments for this subject")
						.font(.quicksand())
				}
			}
			else {
				List {
					if !examsList.isEmpty {
						ExamsListView()
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
						let nextSortOrder = subject.tasks
							.filter { !$0.isCompleted && $0.priority != .exam }
							.map(\.sortOrder)
							.max() ?? -1

						subject.tasks.append(.init(title: "", priority: .normal, sortOrder: nextSortOrder + 1))
					}
				}
				.font(.quicksand())
				.foregroundStyle(.primary)
				.frame(width: 120, height: 50)
				.background(Color.irisSlateBlue, in: .capsule)
				.padding(.bottom, 20)
				.shadow(color: .irisSlateBlue, radius: 4)
			}
			.frame(maxWidth: .infinity)
			.background(
				subject.tasks.isEmpty ? Color(uiColor: .systemBackground) : Color(uiColor: .systemGroupedBackground)
			)
		}
	}

	@ViewBuilder
	private func ExamsListView() -> some View {
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
			.onMove { indices, offset in
				Task {
					try? await Task.sleep(for: .seconds(1.35))

					var tasks = pendingAssignments
						.filter { !$0.isCompleted && $0.priority != .exam }
						.sorted(using: SortDescriptor(\.sortOrder))

					tasks.move(fromOffsets: indices, toOffset: offset)

					for (index, task) in tasks.enumerated() {
						task.sortOrder = index
					}
				}
			}
		}
	}
}

/// View that'll show the completed assignments
private struct CompletedAssignmentsView: View {
	let subject: Subject
	@State private var showAll = false

	private var filteredTasks: [Subject.Task] {
		return subject.tasks.filter { $0.isCompleted }.sorted(using: SortDescriptor(\.sortOrder))
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
