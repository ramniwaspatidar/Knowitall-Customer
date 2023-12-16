

import Foundation
import UIKit
import SideMenu

class MainCoordinator : Coordinator{
    func start() {
        
    }
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func goToOTP(_ verificationID : String,_ mobileNumber : String) {
        let vc = OTPViewController.instantiate()
        vc.coordinator = self
        vc.verificationID = verificationID
        vc.mobileNumber = mobileNumber
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToMobileNUmber() {
        let vc = SigninViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    func goToLocation() {
        let vc = LocationViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToLocationRequest(addressArray : [AddressTypeModel]) {
        let vc = RequestViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.addressInfo = addressArray

        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToAddressView(addressArray : [AddressTypeModel]) {
        let vc = AddressViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.infoArray = addressArray
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToTrackingView() {
        let vc = TrackingViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToArrivalView() {
        let vc = ArrivalViewControoler.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToMainMenuView() {
        let vc = MainViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    func goToHelpView() {
        let vc = HelpViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    func goToSideMenu(window : UIWindow) {
        
        
        let vc = SideMenuTableViewController.instantiate()
        vc.coordinator = self

            SideMenuManager.default.leftMenuNavigationController = UISideMenuNavigationController(rootViewController: vc)
            SideMenuManager.default.addPanGestureToPresent(toView: window)
            SideMenuManager.default.menuWidth = 350
        
        

    }
    
    
}
