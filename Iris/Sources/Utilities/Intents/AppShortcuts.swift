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
			intent: CompletedAssignmentIntent(),
			phrases: ["Complete assignment in \(.applicationName)"],
			shortTitle: "Complete assignment",
			systemImageName: "checkmark"
		)
		AppShortcut(
			intent: NewAssignmentIntent(),
			phrases: ["Create a new assignment in \(.applicationName)"],
			shortTitle: "Create assignment",
			systemImageName: "square.and.pencil"
		)

		AppShortcut(
			intent: StartNewTimerIntent(),
			phrases: ["Start a new timer in \(.applicationName)"],
			shortTitle: "Start new timer",
			systemImageName: "timer"
		)
		AppShortcut(
			intent: TakeSubjectIntent(),
			phrases: ["Take a new subject in \(.applicationName)"],
			shortTitle: "Take subject",
			systemImageName: "books.vertical"
		)
	}
}
