

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
    func goToPDFView() {
        let vc = PDFViewController.instantiate()
        vc.coordinator = self
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
    
    func goToTrackingView(_ requestId : String,_ isMenu : Bool = false) {
        let vc = TrackingViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.requestId = requestId
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
    
    func goToUpdateProfile(_ userNotExist : Bool = false) {
        let vc = UpdateProfileViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    func goToRequest() {
        let vc = RequestListViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToWebview(type : WebViewType){
        let vc = WKWebViewController.instantiate()
        vc.coordinator = self
        vc.webViewType = type
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToProfile(_ number : String){
        let vc = ProfileViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.mobileNumber = number
        navigationController.pushViewController(vc, animated: false)
    }
      
}
