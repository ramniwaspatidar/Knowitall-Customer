
import UIKit
import FirebaseAuth
import Firebase
//import FirebaseDatabase
//import FirebaseFirestore
import CoreLocation
import MapKit
import SDWebImage
import AVFoundation


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
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var driverImageButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var driverViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var adImageContainer: UIView!
    @IBOutlet weak var adImageView: UIImageView!
    
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var adVideoView: UIView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var adImageSkipButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    var timer : Timer?
    
    var adTimer: Timer?
    var ad5SecTimer: Timer?
    var adCounter = 5;
    var currentAdIndex = 0
    
    // For video ad
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var timeObserverToken: Any?
    
    @IBAction func adImageSkipButton_Clicked(_ sender: Any) {
        if(adImageContainer.isHidden == false){
            adImageContainer.isHidden = true
            stopAndReleasePlayer()
        }
        startAdTimer()
    }
    @IBAction func muteButton_Clicked(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        self.player?.isMuted = !muteButton.isSelected
    }
    
    var viewModel : TrackingViewModel = {
        let model = TrackingViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adImageContainer.isHidden = true
        
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
        
        if(viewModel.dictRequest != nil && viewModel.dictRequest?.driverArrived == true && viewModel.dictRequest?.confirmArrival == false){
            self.viewModel.infoArray.removeAll()
            self.viewModel.infoArray = self.viewModel.prepareInfo()
            self.updateUI()
            coordinator?.goToArrivalView(viewModel.dictRequest!)
        }
        self.view.bringSubviewToFront(adImageContainer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        if(self.player != nil){
            player?.play()
        }
        else{
            self.startAdTimer()
        }
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
        self.adTimer?.invalidate()
        self.adTimer = nil
    }
    
    func getRequestDetails(_ isLoading : Bool = true){
        viewModel.getRequestData(APIsEndPoints.kGetCustor.rawValue + (viewModel.requestId ), isLoading) { response, code in
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
            if(self.adImageContainer.isHidden == true){
                self.getRequestDetails(true)
            }
            else{
                self.getRequestDetails(false)
            }
        })
    }
    
    func startAdTimer() {
        self.adTimer?.invalidate()
        self.adTimer = nil
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let adTimePeriod = appDelegate.adsData["adTimePeriod"] as? TimeInterval else {
            return
        }
        self.adTimer = Timer.scheduledTimer(withTimeInterval: adTimePeriod, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            // Retrieve and process the ad order string
            guard let strOrder = appDelegate.adsData["adOrder"] as? String else {
                return
            }
            // Convert the ad order string to an array of integers
            let orders = strOrder.split(separator: ",").compactMap {
                Int($0.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            // Check if orders array is empty
            if orders.isEmpty {
                return
            }
            
            // Check if the current ad index is within the bounds of the orders array
            if self.currentAdIndex >= orders.count {
                self.currentAdIndex = 0
            }
            
            // Retrieve the ads array and find the current ad to display
            if let ads = appDelegate.adsData["ads"] as? [[String: Any]], let adNumber = orders[safe:self.currentAdIndex], let ad = ads.first(where: { $0["adNumber"] as? Int == adNumber }) {
                self.displayAd(ad)
                self.currentAdIndex += 1
            }
        }
    }

    func displayAd(_ ad: [String:Any]) {
        if let adType = ad["adType"] as? String,let adURL = ad["adUrl"] as? String, let adId = ad["adId"] as? String {
            let extensionName = URL(string: adURL)?.pathExtension ?? ""
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(adId).\(extensionName)")
            print(destinationURL)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                switch adType {
                case "Image":
                    if let image = UIImage(contentsOfFile: destinationURL.path) {
                        adImageContainer.isHidden = false
                        adVideoView.isHidden = true
                        adImageView.isHidden = false
                        adImageView.image = image
                        startAdCounterTimer()
                    } else {
                        startAdTimer()
                    }
                case "Video":
                    self.progressBar.setProgress(0.0, animated:true)
                    adImageContainer.isHidden = false
                    adVideoView.isHidden = false
                    adImageView.isHidden = true
                    print("destinationURL", destinationURL)
                    let player1 = AVPlayer(url: URL(fileURLWithPath: destinationURL.path))
                    let playerLayer1 = AVPlayerLayer(player: player1)
                    playerLayer1.frame = mediaView.bounds
                    playerLayer1.videoGravity = .resizeAspect
                    mediaView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clean existing layers
                    mediaView.layer.addSublayer(playerLayer1)
                    let interval = CMTime(value: 1, timescale: 1)
                    timeObserverToken = player1.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [self] (progressTime) in
                        let seconds = CMTimeGetSeconds(progressTime)
                        //lets move the slider thumb
                        if let duration = self.player?.currentItem?.duration {
                            let durationSeconds = CMTimeGetSeconds(duration)
                            let progress = Float(seconds / durationSeconds)
                            let roundedProgress = Float(String(format: "%.2f", progress)) ?? 0.0
                            print("duration",roundedProgress)
                            if(roundedProgress < 0){
                                self.progressBar.setProgress(0.0, animated:true)
                            }else if(roundedProgress >= 1){
                                self.progressBar.setProgress(1.0, animated:true)
//                                adImageContainer.isHidden = true
//                                startAdTimer()
                            }
                            else{
                                self.progressBar.setProgress(roundedProgress, animated:true)
                            }
                        }
                    })
                    
                    player1.play()
                    player1.isMuted = true
                    muteButton.isSelected = false
                    startAdCounterTimer()
                    self.player = player1
                    self.playerLayer = playerLayer1
                    
                    break
                default:
                    break
                }
            }
        }
        

    }
    
    func stopAndReleasePlayer() {
        self.player?.pause()
        
        if let timeObserverToken = self.timeObserverToken {
            self.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        self.playerLayer?.removeFromSuperlayer()
        
        self.player = nil
        self.playerLayer = nil
        
    }
    
    func startAdCounterTimer() {
        adImageSkipButton.isUserInteractionEnabled = false
        adImageSkipButton.setTitle("Close AD (5 sec)", for: UIControl.State.normal)
        self.adCounter = 5  // Assuming you want to start the counter at 5 seconds.
        self.ad5SecTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.adCounter -= 1
            
            if self.adCounter == 0 {
                self.ad5SecTimer?.invalidate()
                self.ad5SecTimer = nil
                self.adImageSkipButton.setTitle("Close AD", for: .normal)
                self.adImageSkipButton.isUserInteractionEnabled = true
            } else {
                self.adImageSkipButton.setTitle("Close AD (\(self.adCounter) sec)", for: .normal)
            }
        }
    }
    
    fileprivate func setupUI(){
        userName.text = ""
        vehicleNumber.text = ""
        TrackingCell.registerWithTable(tblView)
        requestId.text = "\(viewModel.dictRequest?.reqDispId ?? "")"
        serviceLabel.text = "Service : \(viewModel.dictRequest?.typeOfService ?? "")"
        if (viewModel.dictRequest?.driverId) != nil{
            driverView.isHidden = false
            var frame = headerView.frame
            frame.size.height = 160.0
            headerView.frame = frame
            if let username = viewModel.dictRequest?.driverName{
                userName.text = username
                vehicleNumber.text = "(\(viewModel.dictRequest?.driverVehicleNumber ?? ""))"
            }
            let str  = viewModel.dictRequest?.driverProfileImage ?? ""
            userImage?.layer.cornerRadius = 25
            userImage?.clipsToBounds = true
            userImage?.layer.borderWidth = 2
            userImage?.layer.borderColor = UIColor(hexString: "#C837AB").cgColor
            if(str.count > 0){
                activityIndicator.startAnimating()
                if let imageUrl = URL(string: str) {
                    self.userImage.sd_setImage(with: imageUrl) { [weak self] (image, error, cacheType, url) in
                        // Stop the activity indicator when the image loading is completed
                        self?.activityIndicator.stopAnimating()
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        else{
            driverView.isHidden = true
            var frame = headerView.frame
            frame.size.height = 90.0
            headerView.frame = frame
        }

    }
    
    @IBAction func onClickUserImageButton(_ sender: Any) {
        let str  = viewModel.dictRequest?.driverProfileImage ?? ""
        if(str.count > 0){
            coordinator?.goToProfileIMageView(url: viewModel.dictRequest?.driverProfileImage ?? "")
        }
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
            self.tblView.reloadData()
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



extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
