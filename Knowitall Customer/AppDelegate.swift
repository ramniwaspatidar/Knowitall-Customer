import UIKit
import CoreLocation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SideMenu
import IQKeyboardManagerSwift

protocol locationDelegateProtocol {
    func getUserCurrentLocation()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MessagingDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var delegate: locationDelegateProtocol? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().unselectedItemTintColor = hexStringToUIColor("#393F45")
        UITabBar.appearance().tintColor = hexStringToUIColor("#E31D7C")
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        IQKeyboardManager.shared.enable = true


        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        

        
        autoLogin()
        return true
    }
    
    fileprivate func tabbarSetting(){
        UITabBar.appearance().unselectedItemTintColor = hexStringToUIColor("#BABABA")
        UITabBar.appearance().tintColor = hexStringToUIColor("#E31D7C")
        
        // add Shadow
        UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -3)
        UITabBar.appearance().layer.shadowRadius = 3
        UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UITabBar.appearance().layer.shadowOpacity = 1
        UITabBar.appearance().layer.applySketchShadow(color: .white, alpha: 1, x: 0, y: -3, blur: 10)
        
        //        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().barTintColor = .white
        
    }
    
    // Mark : get app version
    
    public func autoLogin(){
        if let currentUser = Auth.auth().currentUser {
            CurrentUserInfo.userId = currentUser.uid
            Messaging.messaging().subscribe(toTopic: CurrentUserInfo.userId) { error in
                if let error = error {
                    print("Error subscribing from topic: \(error.localizedDescription)")
                } else {
                    print("Successfully subscribed from topic!")
                }
            }
            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToHelpView()

        }else{
            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToMobileNUmber()
        }
        
//        let navController = UINavigationController()
//        navController.navigationBar.isHidden = true
//        coordinator = MainCoordinator(navigationController: navController)
//        coordinator?.goToHelpView()
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator?.navigationController
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        let sideMenuViewController = SideMenuTableViewController()
        sideMenuViewController.coordinator = coordinator
            SideMenuManager.default.leftMenuNavigationController = UISideMenuNavigationController(rootViewController: sideMenuViewController)
            SideMenuManager.default.addPanGestureToPresent(toView: self.window!)
        SideMenuManager.default.menuWidth = (self.window?.frame.size.width ?? 350) - 100

    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            print("FCM Token:", fcmToken ?? "")
            // Send the FCM token to your server if needed
        }
}


public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

func getTopViewController() -> UIViewController? {
    let appDelegate = UIApplication.shared.delegate
    if let window = appDelegate!.window {
        return window?.visibleViewController
    }
    return nil
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if ((CurrentUserInfo.userId) != nil) {
            let userInfo = response.notification.request.content.userInfo
            let notiType = userInfo["notificationType"] as? String
            if(notiType == "request_accept" || notiType == "driver_arrived"){
                let requestId = userInfo["requestId"] as? String
                coordinator?.goToTrackingView(requestId ?? "",false)
                
            }
        }
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
        
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("\(#function)")
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
    
}
