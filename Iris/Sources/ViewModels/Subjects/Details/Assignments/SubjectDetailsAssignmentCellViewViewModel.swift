//
//  SubjectDetailsAssignmentCellViewViewModel.swift
//  Iris
//
//  Created by Luki on 17/09/2024.
//

import UserNotifications

/// View model class for SubjectDetailsAsssignmentCellView
final class SubjectDetailsAssignmentCellViewViewModel {

	/// Function to schedule a notification for the given exam date
	/// - Parameters:
	/// 	- examDate: The exam date
	/// 	- subject: The current subject
	///		- daysLeftBeforeTheExam: An integer that represents when the notification should be fired before the exam date
	func scheduleNotification(for examDate: Date, subject: Subject, daysLeftBeforeTheExam: Int) {
		let calendar = Calendar.current

		let notificationDate = calendar.date(byAdding: .day, value: -daysLeftBeforeTheExam, to: examDate)!
		guard notificationDate > .now else { return }

		let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)

		let content = UNMutableNotificationContent()
		content.title = "Upcoming Exam"
		content.body = "Your \(subject.name) exam is less than \(daysLeftBeforeTheExam) days away"
		content.sound = .default

		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

		UNUserNotificationCenter.current().add(request)
	}

	/// Function to remove all pending notification requests
	func removePendingNotificationRequests() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}

}
