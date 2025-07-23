//
//  StartNewTimerIntent.swift
//  Iris
//
//  Created by Luki on 23/07/2025.
//

import AppIntents
import UIKit.UIApplication

/// App intent to start a new pomodoro timer
struct StartNewTimerIntent: AppIntent {
	static let title: LocalizedStringResource = "Start a new timer"
	static let openAppWhenRun = true

	@MainActor
	private var tabBarVC: TabBarVC? {
		guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
		return scene.windows.first?.rootViewController as? TabBarVC
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		try? await Task.sleep(for: .seconds(0.4))

		tabBarVC?.selectedIndex = 2
		NotificationCenter.default.post(name: .didStartNewTimerNotification, object: nil)
		return .result()
	}
}
