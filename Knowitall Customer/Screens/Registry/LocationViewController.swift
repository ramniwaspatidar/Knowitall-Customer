

import UIKit
import CoreLocation
import SVProgressHUD


class LocationViewController: UIViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    let locationManager = CLLocationManager()
    
    var viewModel : AddressViewModel = {
        let model = AddressViewModel()
        return model
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        SVProgressHUD.show()
        
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        coordinator?.goToLocationRequest(self.viewModel.infoArray)
    }
    
    
    
}
extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0] // The first location in the array
        print("location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
        
        self.viewModel.getAddressFromLatLon(latitude: "\(userLocation.coordinate.latitude)", withLongitude: "\(userLocation.coordinate.longitude)",handler: {address in
            self.coordinator?.goToLocationRequest(self.viewModel.infoArray)

        })
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        //        Alert(title: "Error", message: error.localizedDescription, vc: self)
        
    }
}






