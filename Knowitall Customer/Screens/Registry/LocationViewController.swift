

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
        coordinator?.goToLocationRequest(addressArray: self.viewModel.infoArray)

    }
    
    func getAddressFromLatLon(latitude: String, withLongitude longitude: String) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = Double("\(latitude)")!
            let lon: Double = Double("\(longitude)")!
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                   
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                            self.viewModel.infoArray[0].value = addressString
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                            self.viewModel.infoArray[1].value = pm.thoroughfare!

                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                            self.viewModel.infoArray[2].value = pm.locality!

                        }
                        
                        if pm.administrativeArea != nil {
                            addressString = addressString + pm.administrativeArea! + ", "

                        }
                        
                        
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                            self.viewModel.infoArray[3].value = pm.locality!

                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        SVProgressHUD.dismiss()
                        self.viewModel.infoArray[4].value = addressString
                        self.coordinator?.goToLocationRequest(addressArray: self.viewModel.infoArray)


                  }
            })

        }
    
    
}
extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0] // The first location in the array
        print("location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
        
        self.getAddressFromLatLon(latitude: "\(userLocation.coordinate.latitude)", withLongitude: "\(userLocation.coordinate.longitude)")

    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
//        Alert(title: "Error", message: error.localizedDescription, vc: self)
        
    }
}






