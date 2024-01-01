

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
    
    func goToLocationRequest(_ addressArray : [AddressTypeModel]) {
        let vc = RequestViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.addressInfo = addressArray
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToAddressView(addressArray : [AddressTypeModel],delegate : AddressChangeDelegate) {
        let vc = AddressViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.infoArray = addressArray
        vc.addressDelegate = delegate
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToTrackingView(_ dict : RequestListModal,_ isMenu : Bool = false) {
        let vc = TrackingViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.dictRequest = dict
        vc.viewModel.isMenu = isMenu
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToArrivalView(_ dictRequest : RequestListModal) {
        let vc = ArrivalViewControoler.instantiate()
        vc.coordinator = self
        vc.dictRequest = dictRequest
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
    
    func goToRequest() {
        let vc = RequestListViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
//    func goToSideMenu(window : UIWindow) {
//        
//        let vc = SideMenuTableViewController.instantiate()
//        vc.coordinator = self
//
//            SideMenuManager.default.leftMenuNavigationController = UISideMenuNavigationController(rootViewController: vc)
//            SideMenuManager.default.addPanGestureToPresent(toView: window)
//            SideMenuManager.default.menuWidth = 350
//        
//        
//
//    }
    
    
}
