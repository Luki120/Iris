import UIKit

/// Coordinator which will take care of navigation events related to GradesVC
final class GradesCoordinator: Coordinator {

    enum Event {}

    var navigationController = UINavigationController()

    init() {
        let gradesVC = GradesVC()
        gradesVC.title = "Grades"
		gradesVC.tabBarItem = UITabBarItem(title: "Grades", image: UIImage(resource: .chart), tag: 1)

        navigationController.viewControllers = [gradesVC]
    }

    func eventOccurred(with event: Event) {}

}
