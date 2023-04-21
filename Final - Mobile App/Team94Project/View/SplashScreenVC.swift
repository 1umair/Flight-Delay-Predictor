
import UIKit

class SplashScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.navigateToMain()
        }

    }

    func navigateToMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: AppStoryboard.Main.rawValue, bundle: nil)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: UITabBarController.storyboardID) as? UITabBarController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate,
                let window = sceneDelegate.window {
                window.rootViewController = viewController
                window.makeKeyAndVisible()
            }
        }
    }
}
