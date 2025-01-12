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

/// View model class for PomodoroTimerView
@Observable
final class PomodoroTimerViewViewModel {

	var showAlert = false
	var createNewTimer = false

	var minutes = 60
	var breakMinutes = 20

	private var isBreak = false
	private var seconds = 0
	private var totalSeconds = 0
	private var totalStaticSeconds = 0
	private var lastActiveTimestamp = Date()

	private(set) var session: Session = .study
	private(set) var timerState: TimerState = .inactive
	private(set) var progress: CGFloat = 1
	private(set) var timerString = "00:00"

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

		if isBreak {
			timerString = "\(breakMinutes):\(seconds < 10 ? "0" : "")\(seconds)"
			totalSeconds = breakMinutes * 60
			totalStaticSeconds = totalSeconds
			scheduleNotification(forSession: .break)
		}
		else {
			timerString = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
			totalSeconds = (minutes * 60) + seconds
			totalStaticSeconds = totalSeconds
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

		scheduleNotification(forSession: isBreak ? .break : .study)
	}

	func updateTimer() {
		guard timerState == .active(isPaused: false) else { return }

		totalSeconds -= 1
		progress = CGFloat(totalSeconds) / CGFloat(totalStaticSeconds)
		progress = max(progress, 0)
		minutes = (totalSeconds / 60) % 60
		seconds = totalSeconds % 60
		timerString = "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"

		guard totalSeconds == 0 else { return }
		timerState = .inactive

		if isBreak {
			isBreak = false
			session = .study
			stopTimer()
		}
		else {
			isBreak = true
			session = .break
			startTimer()
		}
	}

	func stopTimer() {
		withAnimation {
			timerState = .inactive
			breakMinutes = 0
			minutes = 0
			seconds = 0
			progress = 1
		}
		if session != .study {
			isBreak = false
			session = .study
		}
		timerString = "00:00"
		totalSeconds = 0
		totalStaticSeconds = 0

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

		Task {
			try? await UNUserNotificationCenter.current().setBadgeCount(0)
		}

		let elapsedTime = Int(Date().timeIntervalSince(lastActiveTimestamp))

		if totalSeconds - elapsedTime <= 0 {
			timerState = .inactive
			progress = 1
			minutes = 0
			seconds = 0
			totalSeconds = 0

			if !isBreak {
				session = .break
				isBreak = true
				startTimer()
			}
			else {
				session = .study
				isBreak = false
				timerString = "00:00"
				breakMinutes = 0
			}
		}
		else {
			totalSeconds -= elapsedTime
		}
	}
}

// MARK: - UserNotifications

extension PomodoroTimerViewViewModel {
	private func scheduleNotification(forSession session: Session) {
		let content = UNMutableNotificationContent()
		content.title = "Pomodoro Timer"
		content.body = session == .study ? "Study session finished, starting break" : "Break finished, get back to work!"
		content.badge = 1
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalSeconds), repeats: false)
		let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

		UNUserNotificationCenter.current().add(request)
	}
}
