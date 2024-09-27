//
//  AssignmentsCellView.swift
//  Iris
//
//  Created by Luki on 12/09/2024.
//

import SwiftUI

/// Struct to represent the assignment cell for the assignments view
struct SubjectDetailsAssignmentCellView: View {

	let subject: Subject
	@Bindable private(set) var task: Subject.Task

	@State private var viewModel = SubjectDetailsAssignmentCellViewViewModel()
	@FocusState private var isActive: Bool

	var body: some View {
		HStack {
			if !isActive && !task.title.isEmpty {
				Button {
					withAnimation(.snappy) {
						task.isCompleted.toggle()
					}
				} label: {
					Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
						.contentShape(.rect)
						.contentTransition(.symbolEffect(.replace))
						.font(.title2)
						.foregroundStyle(task.isCompleted ? .gray : .primary)
						.padding(2.5)
				}
			}
			TextField("", text: $task.title)
				.focused($isActive)
				.foregroundStyle(task.isCompleted ? .gray : .primary)
				.strikethrough(task.isCompleted)

			if !isActive && !task.title.isEmpty {
				if task.priority == .exam {
					VStack {
						Text(task.examDate.formatted(.dateTime.day().month().year()))
							.font(.caption)
					}
					.overlay {
						DatePicker(selection: $task.examDate, displayedComponents: .date) {}
							.blendMode(.destinationOver)
							.labelsHidden()
							.onChange(of: task.examDate) { _,  newDate in
								viewModel.removePendingNotificationRequests()

								viewModel.scheduleNotification(for: newDate, subject: subject, daysLeftBeforeTheExam: 10)
								viewModel.scheduleNotification(for: newDate, subject: subject, daysLeftBeforeTheExam: 5)
							}
					}
				}
			}

			if !isActive && !task.title.isEmpty {
				Menu("", systemImage: "circle.fill") {
					ForEach(Subject.Task.Priority.allCases, id: \.rawValue) { priority in
						Button {
							withAnimation(.snappy) {
								task.priority = priority
							}
						} label: {
							HStack {
								Text(priority.rawValue)

								if task.priority == priority {
									Image(systemName: "checkmark")
								}
							}
						}
					}
				}
				.contentShape(.rect)
				.font(.title2)
				.foregroundStyle(task.priority.color.gradient)
				.padding(2.5)

			}
		}
		.onAppear {
			isActive = task.title.isEmpty
		}
		.animation(.snappy, value: isActive)
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			guard task.title.isEmpty else { return }
			deleteTask()
		}
		.onSubmit(of: .text) {
			guard task.title.isEmpty else { return }
			deleteTask()
		}
		.swipeActions(edge: .trailing) {
			Button("", systemImage: "trash", role: .destructive) {
				deleteTask()
			}
		}
	}

	private func deleteTask() {
		guard let index = subject.tasks.firstIndex(where: { $0 === task }) else { return }

		withAnimation(.snappy) {
			_ = subject.tasks.remove(at: index)
		}

		SubjectsManager.shared.context?.delete(task)
		try? SubjectsManager.shared.context?.save()
	}
}
