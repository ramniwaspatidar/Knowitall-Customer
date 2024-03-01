import UIKit
import CoreLocation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SideMenu
import IQKeyboardManagerSwift
import AppsFlyerLib

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
    
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "TRhhpejLoKpVVJWvUcTUy3"
        AppsFlyerLib.shared().appleAppID = "6476615478"
        
        // Set AppsFlyer delegate
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        
        AppsFlyerLib.shared().appInviteOneLinkID = "fuwH"
        //
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //        let branch: Branch = Branch.getInstance()
        //        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
        //            if error == nil {  // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
        //                // params will be empty if no data found
        //                // Logic handling
        //                print("params: %@", params as? [String: AnyObject] ?? {})
        //                if let referralCode = params!["referral_code"] as? String {
        //                    UserDefaults.standard.set(referralCode, forKey: "referralCode")
        //                    UserDefaults.standard.synchronize()
        //                    print("Referral code: \(referralCode)")
        //                    // Do something with the referral code (e.g., attribute referral to user)
        //                }
        //            }
        //        })
        
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
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
        let navController = UINavigationController()
        navController.navigationBar.isHidden = true
        if CurrentUserInfo.userId != nil ,let currentUser = Auth.auth().currentUser {
            CurrentUserInfo.userId = currentUser.uid
            Messaging.messaging().subscribe(toTopic: CurrentUserInfo.userId) { error in
                if let error = error {
                    print("Error subscribing from topic: \(error.localizedDescription)")
                } else {
                    print("Successfully subscribed from topic!")
                }
            }
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToHelpView()
            
        }else{
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToMobileNUmber()
        }
        if(window != nil){
            window?.rootViewController = coordinator?.navigationController
        }
        else{
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = coordinator?.navigationController
            window?.makeKeyAndVisible()
        }
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        let sideMenuViewController = SideMenuTableViewController()
        sideMenuViewController.coordinator = coordinator
        SideMenuManager.default.leftMenuNavigationController = SideMenuNavigationController(rootViewController: sideMenuViewController)
        SideMenuManager.default.addPanGestureToPresent(toView: self.window!)
        SideMenuManager.default.menuWidth = (self.window?.frame.size.width ?? 350) - 100
        
    }

    public func signout(){
        do{
            try Auth.auth().signOut()
            
            Messaging.messaging().unsubscribe(fromTopic: CurrentUserInfo.userId) { error in
                if let error = error {
                    print("Error unsubscribing from topic: \(error.localizedDescription)")
                } else {
                    print("Successfully unsubscribed from topic!")
                }
            }
            
            
            
            CurrentUserInfo.email = nil
            CurrentUserInfo.phone = nil
            CurrentUserInfo.language = nil
            CurrentUserInfo.location = nil
            CurrentUserInfo.userId = nil
            autoLogin()
        }catch{
            
        }
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
            if(notiType == "request_accept" || notiType == "driver_arrived" || notiType == "request_completed" || notiType == "request_cancelled"){
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
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
    
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//        print("\(#function)")
//        if Auth.auth().canHandle(url) {
//            return true
//        }
//        if let deepLinkData = options[.sourceApplication] as? [String: Any] {
//            handleDeepLinkData(deepLinkData)
//        }
//        return false
//    }
    
    //    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {let branchHandled = Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    //        if (!branchHandled) {
    //      // If not handled by Branch, do other deep link routing for the   Facebook SDK, Pinterest SDK, etc
    //      }
    //     return true
    //    }
    
    //    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    //    // pass the url to the handle deep link call
    //      Branch.getInstance().continue(userActivity)
    //     return true
    //    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
            
    // Open URI-scheme for iOS 9 and above
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
}

extension AppDelegate: DeepLinkDelegate {
     
    func didResolveDeepLink(_ result: DeepLinkResult) {
        var fruitNameStr: String?
        switch result.status {
        case .notFound:
            NSLog("[AFSDK] Deep link not found")
            return
        case .failure:
            print("Error %@", result.error!)
            return
        case .found:
            NSLog("[AFSDK] Deep link found")
        }
        
        guard let deepLinkObj:DeepLink = result.deepLink else {
            NSLog("[AFSDK] Could not extract deep link object")
            return
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub2") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub2"] as! String
            UserDefaults.standard.set(ReferrerId, forKey: "referralCode")
            UserDefaults.standard.synchronize()
            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
        } else {
            NSLog("[AFSDK] Could not extract referrerId")
        }
        
        let deepLinkStr:String = deepLinkObj.toString()
        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
        
        
            if( deepLinkObj.isDeferred == true) {
                NSLog("[AFSDK] This is a deferred deep link")
            }
            else {
                NSLog("[AFSDK] This is a direct deep link")
            }
        
        fruitNameStr = deepLinkObj.deeplinkValue
        
        //If deep_link_value doesn't exist
        if fruitNameStr == nil || fruitNameStr == "" {
            //check if fruit_name exists
            switch deepLinkObj.clickEvent["fruit_name"] {
                case let s as String:
                    fruitNameStr = s
                default:
                    print("[AFSDK] Could not extract deep_link_value or fruit_name from deep link object with unified deep linking")
                    return
            }
        }
        
//        walkToSceneWithParams(fruitName: fruitNameStr!, deepLinkData: deepLinkObj.clickEvent)
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        // Handle attribution data received when app is opened from a deep link
        if let deepLinkData = attributionData as? [String: Any] {
        }
    }
}

