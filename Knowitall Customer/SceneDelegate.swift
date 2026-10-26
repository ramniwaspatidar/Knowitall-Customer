import UIKit
import FirebaseAuth
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appDelegate.window = window
        appDelegate.autoLogin()
        window.makeKeyAndVisible()

        if let urlContext = connectionOptions.urlContexts.first {
            _ = handle(url: urlContext.url, options: urlContext.options)
        }

        if let userActivity = connectionOptions.userActivities.first {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.sceneDidBecomeActive()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        _ = handle(url: urlContext.url, options: urlContext.options)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }

    private func handle(url: URL, options: UIScene.OpenURLOptions) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }

        AppsFlyerLib.shared().handleOpen(
            url,
            options: [
                UIApplication.OpenURLOptionsKey.sourceApplication: options.sourceApplication as Any,
                UIApplication.OpenURLOptionsKey.annotation: options.annotation as Any
            ]
        )
        return true
    }
}
