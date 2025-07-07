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

		let notificationDate = calendar.date(byAdding: .day, value: -daysBeforeTheExam, to: examDate)!
		let sameDayDate = calendar.date(byAdding: .hour, value: 1, to: examDate)!

		let triggerDateComponents = calendar.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: daysBeforeTheExam == 0 ? sameDayDate : notificationDate
		)

		let bodyMessage: String

		if daysBeforeTheExam == 0 {
			bodyMessage = "Your \(subject.name) exam is today, good luck 🤞🏻🍀"
		}
		else {
			bodyMessage = "Your \(subject.name) exam is less than \(daysBeforeTheExam) days away"
		}

		let content = UNMutableNotificationContent()
		content.title = "Upcoming Exam"
		content.body = bodyMessage
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
