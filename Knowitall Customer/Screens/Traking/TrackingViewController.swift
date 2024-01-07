
import UIKit
import FirebaseAuth
import Firebase
//import FirebaseDatabase
//import FirebaseFirestore
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
    
    var timer : Timer?
    
    
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
         
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        
        self.viewModel.infoArray.removeAll()
//        self.viewModel.infoArray = self.viewModel.prepareInfo()
        self.getRequestDetails()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getRequestDetails(){
        viewModel.getRequestData(APIsEndPoints.kGetCustor.rawValue + (viewModel.requestId )) { response, code in
            
            if (CurrentUserInfo.userId == response.customerId && response.requestId != nil){
                self.viewModel.dictRequest = response
                self.viewModel.infoArray.removeAll()
                self.viewModel.infoArray = self.viewModel.prepareInfo()
                self.updateUI()
                
                let runTimer = response.confirmArrival == true || response.markNoShow == true || response.cancelled == true
                
                if (!runTimer && self.timer == nil){
                    self.startTimer()
                }
            }
            else{
                self.navigationController?.popViewController(animated: false)
                Alert(title: "Error", message: "Request not found", vc: self)
            }
            
        }
    }
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.getRequestDetails()
        })
    }
    
    fileprivate func setupUI(){
        TrackingCell.registerWithTable(tblView)
        requestId.text = "\(viewModel.dictRequest?.reqDispId ?? "")"
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
        
        let jobDone = viewModel.dictRequest?.confirmArrival == true || viewModel.dictRequest?.markNoShow == true || viewModel.dictRequest?.cancelled == true
        
        if(!jobDone && viewModel.dictRequest?.accepted == true){
            self.getETA()
            
        }else{
            self.viewModel.infoArray[2].eta = "ETA: NA"
            self.tblView.reloadData()

        }
    }
    
    
    func getETA(){
        
        self.viewModel.infoArray[2].eta = "ETA: ..."
        
        let lat = viewModel.dictRequest?.latitude ?? 0
        let lng = viewModel.dictRequest?.longitude ?? 0
        
        let driverlat = viewModel.dictRequest?.driverLocation?.latitude ?? 0
        let driverlng =  viewModel.dictRequest?.driverLocation?.longitude ?? 0
        
        
        if(driverlat == 0 && driverlng == 0){
            self.viewModel.infoArray[2].eta = "ETA: NA"
        }
        else{
            
            let destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude:  lng)
            let source = CLLocationCoordinate2D(latitude:driverlat, longitude: driverlng)
            
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
    }
    
    
    func convertTimeIntervalToHoursMinutes(seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        var minutes = Int(seconds / 60) % 60
        let hours = Int(seconds / 3600)
        
        if(minutes <= 1 && hours == 0){
            minutes = 1
        }
        
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
                
                self.getRequestDetails()
                Alert(title: "Cancel Request", message: "Your request cancel successfully", vc: self)
                
            }
        }
        let callDriver = UIAlertAction(title: "Call Driver", style: .default) { action in
            print("Call Driver")
            
            if(self.viewModel.dictRequest?.accepted == true && self.viewModel.dictRequest?.driverPhoneNumber != nil){
                
                guard let url = URL(string: "telprompt://\(self.viewModel.dictRequest?.driverPhoneNumber ?? "")"),
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



