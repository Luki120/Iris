//
//  PomodoroTimerVC.swift
//  Iris
//
//  Created by Luki on 01/10/2024.
//

import class SwiftUI.UIHostingController
import UIKit

/// Controller that'll show the pomodoro timer view
final class PomodoroTimerVC: UIViewController {
	private let hostingController = UIHostingController(rootView: PomodoroTimerView())

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		addChild(hostingController)

		view.backgroundColor = .systemBackground
		view.addSubview(hostingController.view)
		view.pinViewToAllEdges(hostingController.view)
	}
}
