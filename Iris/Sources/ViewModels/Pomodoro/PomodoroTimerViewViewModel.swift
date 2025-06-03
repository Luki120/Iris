//
//  PomodoroTimerViewViewModel.swift
//  Iris
//
//  Created by Luki on 01/10/2024.
//

import Foundation
import UserNotifications
import class UIKit.UIApplication
import func SwiftUI.withAnimation

/// View model class for `PomodoroTimerView`
@MainActor
@Observable
final class PomodoroTimerViewViewModel {
	var createNewTimer = false

	var minutes = 60
	var breakMinutes = 20

	private var totalStaticTime: Duration = .zero
	private var lastActiveTimestamp = Date()

	private(set) var session: Session = .study
	private(set) var totalTime: Duration = .zero
	private(set) var timerState: TimerState = .inactive
	private(set) var progress: CGFloat = 1

	private let notificationId = "IrisPomodoro"

	enum Session: String {
		case study = "Study"
		case `break` = "Break"
	}

	enum TimerState: Equatable {
		case inactive
		case active(isPaused: Bool)
	}

	init() {
		Task {
			try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
		}
	}

	// MARK: - Timer

	func startTimer() {
		guard timerState == .inactive else { return }

		withAnimation(.easeInOut(duration: 0.25)) {
			timerState = .active(isPaused: false)
		}

		if session == .break {
			totalTime = breakMinutes.asDuration
			totalStaticTime = totalTime
		}
		else {
			totalTime = minutes.asDuration
			totalStaticTime = totalTime
			scheduleNotification(forSession: .study)
		}

		createNewTimer = false
		UIApplication.shared.isIdleTimerDisabled = true
	}

	func pauseTimer() {
		guard timerState == .active(isPaused: false) else { return }
		timerState = .active(isPaused: true)

		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
	}

	func resumeTimer() {
		guard timerState == .active(isPaused: true) else { return }
		timerState = .active(isPaused: false)

		scheduleNotification(forSession: session == .break ? .break : .study)
	}

	func updateTimer() {
		guard timerState == .active(isPaused: false) else { return }

		totalTime -= .seconds(1)
		progress = min(max(CGFloat(totalTime.components.seconds) / CGFloat(totalStaticTime.components.seconds), 0), 1)

		guard totalTime <= .zero else { return }
		timerState = .inactive

		if session == .break {
			stopTimer()
		}
		else {
			session = .break
			startTimer()
		}
	}

	func stopTimer() {
		withAnimation {
			timerState = .inactive
			breakMinutes = 20
			minutes = 60
			progress = 1
		}

		session = .study
		totalTime = .zero
		totalStaticTime = .zero

		UIApplication.shared.isIdleTimerDisabled = false
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
	}
}

// MARK: - Background update logic

extension PomodoroTimerViewViewModel {
	/// Function to update the timer when the app goes to the background
	func onBackground() {
		guard timerState == .active(isPaused: false) else { return }
		lastActiveTimestamp = Date()
	}

	/// Function to update the timer when the app comes to the foreground
	func onForeground() {
		guard timerState == .active(isPaused: false) else { return }
		let elapsedTime = Duration.seconds(Date.now.timeIntervalSince(lastActiveTimestamp))

		Task {
			try? await UNUserNotificationCenter.current().setBadgeCount(0)
		}

		guard totalTime - elapsedTime <= .zero else {
			totalTime -= elapsedTime
			return
		}

		let remainingTime = totalTime + breakMinutes.asDuration - elapsedTime

		guard session != .break else {
			stopTimer()
			return
		}

		if remainingTime <= .zero {
			stopTimer()
		}

		else {
			session = .break
			totalTime = remainingTime
			totalStaticTime = breakMinutes.asDuration

			if totalTime > .zero {
				scheduleNotification(forSession: .break)
			}
		}
	}
}

// MARK: - UserNotifications

private extension PomodoroTimerViewViewModel {
	func scheduleNotification(forSession session: Session) {
		let content = UNMutableNotificationContent()
		content.title = "Pomodoro Timer"
		content.body = session == .study ? "Study session finished, starting break" : "Break finished, get back to work!"
		content.badge = 1
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalTime.components.seconds), repeats: false)
		let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

		UNUserNotificationCenter.current().add(request)
	}
}

private extension Int {
	var asDuration: Duration {
		Duration.seconds(self * 60)
	}
}
