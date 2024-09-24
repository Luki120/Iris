//
//  SceneDelegate.swift
//  Iris
//
//  Created by Luki on 30/07/2024.
//

import UIKit

@UIApplicationMain
final class SceneDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }

		let navBarAttributes = [NSAttributedString.Key.font: UIFont.quicksand(withStyle: .medium, size: 17)]
		let navBarLargeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.quicksand(withStyle: .semiBold, size: 25)]
		let tabBarItemAttributes = [NSAttributedString.Key.font: UIFont.quicksand(withStyle: .bold, size: 10)]

		UINavigationBar.appearance().titleTextAttributes = navBarAttributes
		UINavigationBar.appearance().largeTitleTextAttributes = navBarLargeTitleTextAttributes
		UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .normal)

		window = UIWindow(windowScene: windowScene)
		window?.tintColor = .irisSlateBlue
		window?.makeKeyAndVisible()

		Task {
			do {
				let result = try await AuthService.shared.authenticate()

				switch result {
					case .success: window?.rootViewController = TabBarVC()
					case .unauthorized: window?.rootViewController = LoginVC()
				}
			}
			catch {
				print(error.localizedDescription)
				window?.rootViewController = LoginVC()
			}
		}
	}

}
