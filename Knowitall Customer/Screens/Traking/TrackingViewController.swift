
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import CoreLocation
import MapKit

class TrackingViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestId: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var dotHeight: NSLayoutConstraint!
    
    var viewModel : TrackingViewModel = {
        let model = TrackingViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(viewModel.isMenu == false){
            self.setNavWithOutView(.menu , self.view)
        }else{
            self.setNavWithOutView(.back, self.view)
        }
        setupUI()
        
        self.viewModel.infoArray.removeAll()
        self.viewModel.infoArray = self.viewModel.prepareInfo()
        
        viewModel.getRequestData(APIsEndPoints.kGetCustor.rawValue + (viewModel.dictRequest?.requestId ?? "")) { response, code in
            self.viewModel.dictRequest = response
            self.viewModel.infoArray.removeAll()
            self.viewModel.infoArray = self.viewModel.prepareInfo()
            self.updateUI()
        }
    }
    
    fileprivate func setupUI(){
        TrackingCell.registerWithTable(tblView)
        requestId.text = "\(viewModel.dictRequest?.requestId ?? "")"
    }
    
    fileprivate func updateUI(){
        
       

        if(self.viewModel.dictRequest?.confirmArrival == true){
            self.confirmButton.isHidden = true
            self.dotButton.isHidden = true
        }
        else if(self.viewModel.dictRequest?.driverArrived == true){
            self.confirmButton.isUserInteractionEnabled = true
            self.confirmButton.alpha = 1
        }
        
        let currentUserLat = NSString(string: CurrentUserInfo.latitude ?? "0")
        let currentUserLng = NSString(string: CurrentUserInfo.longitude ?? "0")
        
        
        let lat = viewModel.dictRequest?.latitude ?? 0
        let lng = viewModel.dictRequest?.longitude ?? 0
                
        let destinationLocation = CLLocationCoordinate2D(latitude: currentUserLat.doubleValue, longitude:  currentUserLng.doubleValue)
        
        let source = CLLocationCoordinate2D(latitude: lat, longitude:  lng)
        
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: destinationPlacemark)
        let destinationMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            
            var expectedTravelTime = response.routes[0].expectedTravelTime
            let convertedTime = self.convertTimeIntervalToHoursMinutes(seconds: expectedTravelTime)
            self.viewModel.infoArray[2].eta = "ETA : \(convertedTime.hours):\(convertedTime.minutes):00"
            self.tblView.reloadData()
        }
    }
    
    
    func convertTimeIntervalToHoursMinutes(seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        let minutes = Int(seconds / 60) % 60
        let hours = Int(seconds / 3600)
        
        return (hours, minutes)
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        coordinator?.goToArrivalView(viewModel.dictRequest!)
    }
    
    @IBAction func pdfButtonAction(_ sender: Any) {
        coordinator?.goToPDFView()
    }
    
    
    @IBAction func moreButtonActrion(_ sender: Any) {
        let alertController = UIAlertController(title: "Booking Action", message: "", preferredStyle: .actionSheet)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = hexStringToUIColor("#F4CC9E")
        alertController.view.tintColor = UIColor.black
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let canclebooking = UIAlertAction(title: "Cancel Booking", style: .default) { action in
            print("Cancel Booking")
            
            let param = [String : String]()

            self.viewModel.cancelRequest(APIsEndPoints.kCancelRequest.rawValue + (self.viewModel.dictRequest?.requestId ?? ""), param) { response, code in
                
                Alert(title: "Cancel Request", message: "Your request cancel successfully", vc: self)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        let callDriver = UIAlertAction(title: "Call Driver", style: .default) { action in
            print("Call Driver")
            
            if(self.viewModel.dictRequest?.accepted == true && self.viewModel.dictRequest?.phoneNumber != nil){
                
                guard let url = URL(string: "telprompt://\(self.viewModel.dictRequest?.phoneNumber ?? "")"),
                      UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }else{
                Alert(title: "Driver Request", message: "Waiting for acceptance ", vc: self)
            }
        }
        
        alertController.addAction(canclebooking)
        alertController.addAction(callDriver)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// UITableViewDataSource
extension TrackingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: TrackingCell.reuseIdentifier, for: indexPath) as! TrackingCell
        cell.selectionStyle = .none
        
        cell.commiInit(viewModel.infoArray[indexPath.row])
 
        return cell
    }
}

extension TrackingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
}



