import UIKit


@UIApplicationMain
    final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		let navBarAttributes = [NSAttributedString.Key.font: UIFont.quicksand(withStyle: .medium, size: 17)]
		let tabBarItemAttributes = [NSAttributedString.Key.font: UIFont.quicksand(withStyle: .bold, size: 10)]

		UINavigationBar.appearance().titleTextAttributes = navBarAttributes
		UITabBarItem.appearance().setTitleTextAttributes(tabBarItemAttributes, for: .normal)

		window = UIWindow()
		window?.tintColor = .irisSlateBlue
		window?.rootViewController = TabBarVC()
		window?.makeKeyAndVisible()

		return true
	}

}
