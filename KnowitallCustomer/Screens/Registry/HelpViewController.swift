

import UIKit
import SideMenu
class HelpViewController: BaseViewController,Storyboarded {

    var coordinator: MainCoordinator?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.insertSubview(imgView!, belowSubview: self.view)
            // Define the menus
         
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
  
    @IBAction func helpButtonAction(_ sender: Any) {
        coordinator?.goToLocation()
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    }
    




extension HelpViewController: SideMenuNavigationControllerDelegate {
    
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
