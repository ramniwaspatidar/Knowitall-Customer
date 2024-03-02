
import UIKit
import FirebaseAuth
import Firebase
//import FirebaseDatabase
//import FirebaseFirestore
import CoreLocation
import MapKit

class TrackingViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestId: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dotButton: UIButton!
    @IBOutlet weak var dotHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var driverImageButton: UIButton!
    
    var timer : Timer?
    
    
    var viewModel : TrackingViewModel = {
        let model = TrackingViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(viewModel.isMenu == false){
            self.setNavWithOutView(.menu )
        }else{
            self.setNavWithOutView(.back)
        }
        setupUI()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tblView.addSubview(refreshControl)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        
        self.viewModel.infoArray.removeAll()
        self.getRequestDetails(true)
    }
    
    @objc func refresh(_ sender: Any) {
        refreshControl.endRefreshing()
        self.viewModel.infoArray.removeAll()
        self.getRequestDetails(false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getRequestDetails(_ isLoading : Bool = true){
        viewModel.getRequestData(APIsEndPoints.kGetCustor.rawValue + (viewModel.requestId )) { response, code in
            if (CurrentUserInfo.userId == response.customerId && response.requestId != nil){
                self.viewModel.dictRequest = response
                self.viewModel.infoArray.removeAll()
                self.viewModel.infoArray = self.viewModel.prepareInfo()
                self.updateUI()
                
                if(response.isRunning || response.accepted == false){
                    self.timer?.invalidate()
                    self.timer = nil
                    self.startTimer()
                }
                else{
                    self.timer?.invalidate()
                    self.timer = nil
                }

            }
            else{
                self.navigationController?.popViewController(animated: false)
                Alert(title: "Error", message: "Request not found", vc: self)
            }
            
        }
    }
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
            self.getRequestDetails(false)
        })
    }
    
    fileprivate func setupUI(){
        TrackingCell.registerWithTable(tblView)
        requestId.text = "\(viewModel.dictRequest?.reqDispId ?? "")"
        serviceLabel.text = "Service : \(viewModel.dictRequest?.typeOfService ?? "")"
        
        if let username = viewModel.dictRequest?.driverName{
            userName.text = "\(username) (\(viewModel.dictRequest?.driverVehicleNumber ?? ""))"

        }
        let str  = viewModel.dictRequest?.driverProfileImage ?? ""
        
        userImage?.layer.cornerRadius = 25
        userImage?.clipsToBounds = true
         
        
  
        if let url = URL(string: str) {
            
            DispatchQueue.global().async { [weak self] in
                       if let data = try? Data(contentsOf: url) {
                           if let image = UIImage(data: data) {
                               DispatchQueue.main.async {
                                   self?.userImage.image = image
                               }
                           }
                       }
                   }
               }
    }
    @IBAction func onClickUserImageButton(_ sender: Any) {
        coordinator?.goToProfileIMageView(url: viewModel.dictRequest?.driverProfileImage ?? "")
    }
    
    
                                          
    fileprivate func updateUI(){
        setupUI()
        
        if(self.viewModel.dictRequest?.done == true){
            self.confirmButton.isHidden = true
            self.dotButton.isHidden = true
        }
        else if(self.viewModel.dictRequest?.confirmArrival == true){
            self.confirmButton.isHidden = false
            self.dotButton.isHidden = true
            self.confirmButton.setTitle("CALL DRIVER", for: .normal)
            self.confirmButton.alpha = 1
            self.confirmButton.isUserInteractionEnabled = true
        }
        else if(self.viewModel.dictRequest?.driverArrived == true){
            self.confirmButton.isUserInteractionEnabled = true
            self.confirmButton.alpha = 1
        }

        if(viewModel.dictRequest?.isRunning == true){
            self.getETA()
            
        }else{
//            self.viewModel.infoArray[2].eta = "ETA: NA"
//            self.viewModel.infoArray[2].color = "9CD4FC"
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
            self.viewModel.infoArray[2].color = "9CD4FC"
        }
        else{
            
            let source = CLLocationCoordinate2D(latitude: lat, longitude:  lng)
            let destinationLocation = CLLocationCoordinate2D(latitude:driverlat, longitude: driverlng)
            
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
                    self.viewModel.infoArray[2].eta = "ETA : checking"
                    self.viewModel.infoArray[2].status = "done"
                    self.viewModel.infoArray[2].color = "36D91B"
                    self.tblView.reloadData()
                    return
                }
                
                let route = response.routes[0]
                
                let expectedTravelTime = route.expectedTravelTime
                let convertedTime = self.convertTimeIntervalToHoursMinutes(seconds: expectedTravelTime)
                self.viewModel.infoArray[2].eta = "ETA : \(String(format: "%02d", convertedTime.hours)):\(String(format: "%02d", convertedTime.minutes)) minutes"
                self.viewModel.infoArray[2].status = "done"
                self.viewModel.infoArray[2].color = "36D91B"
                self.tblView.reloadData()
            }
        }
    }
    
    func convertTimeIntervalToHoursMinutes(seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        var minutes = Int(seconds / 60) % 60
        let hours = Int(seconds / 3600)
        
        if(minutes <= 1 && hours == 0){
            minutes = 2
        }
        
        return (hours, minutes)
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        if(self.viewModel.dictRequest?.confirmArrival == true){
            guard let url = URL(string: "telprompt://\(self.viewModel.dictRequest?.driverPhoneNumber ?? "")"),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }else{
            coordinator?.goToArrivalView(viewModel.dictRequest!)
        }
    }
    
    @IBAction func pdfButtonAction(_ sender: Any) {
        coordinator?.goToPDFView()
    }
    
    @IBAction func onClickDriverProfile(_ sender: Any) {
    }
    @IBAction func moreButtonActrion(_ sender: Any) {
        let alertController = UIAlertController(title: "Booking Action", message: "", preferredStyle: .actionSheet)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = hexStringToUIColor("#F4CC9E")
        alertController.view.tintColor = UIColor.black
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let canclebooking = UIAlertAction(title: "Cancel Booking", style: .default) { action in
            
            AlertWithAction(title:"Cancel Booking", message: "Are you sure that you want to Cancel Booking?", ["Cancel Booking","No"], vc: self,kAlertRed) { [self] action in
                if(action == 1){
                    
                    let param = [String : String]()
                    
                    self.viewModel.cancelRequest(APIsEndPoints.kCancelRequest.rawValue + (self.viewModel.dictRequest?.requestId ?? ""), param) { response, code in
                        
                        self.getRequestDetails(false)
                        Alert(title: "Cancel Request", message: "Your request was cancelled successfully.", vc: self)
                        
                    }
                }
                
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



