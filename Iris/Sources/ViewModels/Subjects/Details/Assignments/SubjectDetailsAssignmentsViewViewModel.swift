//
//  SubjectDetailsTasksViewViewModel.swift
//  Iris
//
//  Created by Luki on 09/09/2024.
//

import UserNotifications

/// View model struct for SubjectDetailsAssignmentsView
struct SubjectDetailsAssignmentsViewViewModel {
	let subject: Subject

	/// Designated initializer
	/// - Parameters:
	/// 	- subject: The subject
	init(subject: Subject) {
		self.subject = subject

		Task {
			try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
		}
	}
}
