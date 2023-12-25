

import SideMenu

class MainViewController: UIViewController,Storyboarded  {
    
    var coordinator: MainCoordinator?
    @IBOutlet private weak var blackOutStatusBar: UISwitch!
    @IBOutlet private weak var blurSegmentControl: UISegmentedControl!
    @IBOutlet private weak var menuAlphaSlider: UISlider!
    @IBOutlet private weak var menuScaleFactorSlider: UISlider!
    @IBOutlet private weak var presentingAlphaSlider: UISlider!
    @IBOutlet private weak var presentingScaleFactorSlider: UISlider!
    @IBOutlet private weak var presentationStyleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var screenWidthSlider: UISlider!
    @IBOutlet private weak var shadowOpacitySlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupSideMenu()
        updateUI(settings: SideMenuSettings())
//        let menuButton = UIBarButtonItem(title: "Open Menu", style: .plain, target: self, action: #selector(openLeftMenu))
//             navigationItem.leftBarButtonItem = menuButton
    }

   
    @objc func openLeftMenu() {
           present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
       }
//    private func setupSideMenu() {
//        // Define the menus
//        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//
//        // Enable gestures. The left and/or right menus must be set up above for these to work.
//        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
//
//
//    }
    
    private func updateUI(settings: SideMenuSettings) {
//        let styles:[UIBlurEffect.Style] = [.dark, .light, .extraLight]
//        if let menuBlurEffectStyle = settings.blurEffectStyle {
//            blurSegmentControl.selectedSegmentIndex = (styles.firstIndex(of: menuBlurEffectStyle) ?? 0) + 1
//        } else {
//            blurSegmentControl.selectedSegmentIndex = 0
//        }
//
//        blackOutStatusBar.isOn = settings.statusBarEndAlpha > 0
//        menuAlphaSlider.value = Float(settings.presentationStyle.menuStartAlpha)
//        menuScaleFactorSlider.value = Float(settings.presentationStyle.menuScaleFactor)
//        presentingAlphaSlider.value = Float(settings.presentationStyle.presentingEndAlpha)
//        presentingScaleFactorSlider.value = Float(settings.presentationStyle.presentingScaleFactor)
//        screenWidthSlider.value = Float(settings.menuWidth / min(view.frame.width, view.frame.height))
//        shadowOpacitySlider.value = Float(settings.presentationStyle.onTopShadowOpacity)
    }

    @IBAction private func changeControl(_ control: UIControl) {
       
    }

    

    

}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
