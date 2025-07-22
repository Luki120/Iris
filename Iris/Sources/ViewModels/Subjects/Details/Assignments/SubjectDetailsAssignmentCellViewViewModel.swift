//
//  SubjectDetailsAssignmentCellViewViewModel.swift
//  Iris
//
//  Created by Luki on 17/09/2024.
//

import UserNotifications

/// View model class for `SubjectDetailsAsssignmentCellView`
final class SubjectDetailsAssignmentCellViewViewModel {
	/// Function to schedule a notification for the given exam date
	/// - Parameters:
	/// 	- examDate: The exam `Date`
	/// 	- subject: The current `Subject`
	///		- daysBeforeTheExam: An integer that represents when the notification should fire before the exam date
	func scheduleNotification(for examDate: Date, subject: Subject, daysBeforeTheExam: Int) {
		let calendar = Calendar.current
		let bodyMessage: String
		let notificationDate: Date

		var components: DateComponents

		if daysBeforeTheExam == 0 {
			bodyMessage = "Your \(subject.name) exam is today, good luck 🤞🏻🍀"

			components = calendar.dateComponents([.year, .month, .day], from: examDate)
			components.hour = 7
			components.minute = 30
			components.second = 0

			notificationDate = calendar.date(from: components)!
		}
		else {
			bodyMessage = "Your \(subject.name) exam is less than \(daysBeforeTheExam) days away"

			notificationDate = calendar.date(byAdding: .day, value: -daysBeforeTheExam, to: examDate)!
			components = calendar.dateComponents([.year, .month, .day, .hour], from: notificationDate)
		}

		let content = UNMutableNotificationContent()
		content.title = "Upcoming Exam"
		content.body = bodyMessage
		content.sound = .default

		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

		UNUserNotificationCenter.current().add(request)
	}

	/// Function to remove all pending notification requests
	func removePendingNotificationRequests() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
}
