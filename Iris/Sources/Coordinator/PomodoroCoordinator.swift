//
//  PomodoroCoordinator.swift
//  Iris
//
//  Created by Luki on 01/10/2024.
//

import Foundation
import UIKit.UINavigationController

/// Coordinator which will take care of navigation events related to PomodoroTimerVC
final class PomodoroCoordinator: Coordinator {

	enum Event {}

	var navigationController = UINavigationController()

	init() {
		let pomodoroTimerVC = PomodoroTimerVC()
		pomodoroTimerVC.title = "Pomodoro"
		pomodoroTimerVC.tabBarItem = UITabBarItem(title: "Pomodoro", image: UIImage(resource: .timer), tag: 2)

		navigationController.viewControllers = [pomodoroTimerVC]
	}

	func eventOccurred(with event: Event) {}

}
