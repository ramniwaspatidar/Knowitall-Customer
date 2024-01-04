

import UIKit
import SideMenu
import CoreLocation
import SVProgressHUD

class HelpViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    var viewModel : AddressViewModel = {
        let model = AddressViewModel()
        return model
    }()
    
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
        
        super.viewDidLoad()
        self.setNavWithOutView(.menu,self.view)
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    @IBAction func socialAction(_ sender: Any) {
        
        let btn = sender as? UIButton
        
        if(btn?.tag == 1){
            self.openLink("https://www.tiktok.com/@mr_know_it_all_towing?_t=8iXH5Abclig&_r=1")
        }else  if(btn?.tag == 2){
            self.openLink("https://twitter.com/i/flow/login?redirect_after_login=%2FMKIATOWING")
        }
        else  if(btn?.tag == 3){
            self.openLink("https://www.youtube.com/@mrknowitalltowing2258?feature=shared")
            
        }else  if(btn?.tag == 4){
            self.openLink("https://www.facebook.com/MRKNOWITALLTOWING?mibextid=ZbWKwL")
            
        }else  if(btn?.tag == 5){
            self.openLink("https://www.instagram.com/mr.know_it_all_towing/?igsh=MTNlemZrMzg5dDU0Ng%3D%3D")
        }
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        if(CurrentUserInfo.latitude  != nil && CurrentUserInfo.longitude != nil){
            
            self.viewModel.getAddressFromLatLon(latitude: "\(CurrentUserInfo.latitude ?? "0")", withLongitude: "\(CurrentUserInfo.longitude ?? "0")", handler: { [self] address in
                coordinator?.goToLocationRequest(self.viewModel.infoArray)
            })
        }else{
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            SVProgressHUD.show()
        }
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    func openLink(_ urlSting : String){
        if let url = URL(string: urlSting), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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

extension HelpViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0] // The first location in the array
        print("location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
        SVProgressHUD.dismiss()
        
        self.viewModel.getAddressFromLatLon(latitude: "\(userLocation.coordinate.latitude)", withLongitude: "\(userLocation.coordinate.longitude)",handler: {address in
            self.coordinator?.goToLocationRequest(self.viewModel.infoArray)

        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        SVProgressHUD.dismiss()

        switch status {

        case .restricted, .denied:
            coordinator?.goToLocationRequest(self.viewModel.infoArray)
            manager.stopUpdatingLocation()
            break
            
        case .authorizedWhenInUse,.authorizedAlways,.notDetermined:
            manager.startUpdatingLocation()
            break
     
        default:
            break
        }
    }
    
  
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
        SVProgressHUD.dismiss()
    }
}
