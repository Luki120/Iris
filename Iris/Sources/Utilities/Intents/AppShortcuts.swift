//
//  AppShortcuts.swift
//  Iris
//
//  Created by Luki on 23/07/2025.
//

import AppIntents

/// App shortcuts which can be run manually or by invoking Siri
struct AppShortcuts: AppShortcutsProvider {
	@AppShortcutsBuilder
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: NewAssignmentIntent(),
			phrases: ["Use \(.applicationName) to create a new assignment"],
			shortTitle: "Create assignment",
			systemImageName: "book"
		)

		AppShortcut(
			intent: StartNewTimerIntent(),
			phrases: ["Use \(.applicationName) to start a new timer"],
			shortTitle: "Start a new timer",
			systemImageName: "timer"
		)
	}
}
