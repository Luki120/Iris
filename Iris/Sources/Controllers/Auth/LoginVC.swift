//
//  LoginVC.swift
//  Iris
//
//  Created by Luki on 15/09/2024.
//

import class SwiftUI.UIHostingController
import UIKit

/// Controller that'll show the login view
final class LoginVC: UIViewController {
	private let hostingController = UIHostingController(rootView: LoginView())

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		addChild(hostingController)

		view.backgroundColor = .white
		view.addSubview(hostingController.view)
		view.pinViewToAllEdges(hostingController.view)
	}
}
