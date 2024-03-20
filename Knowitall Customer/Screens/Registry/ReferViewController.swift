

import UIKit
import AppsFlyerLib
import ObjectMapper

class ReferViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?

    @IBOutlet weak var shareButton: UIButton!
  
    @IBOutlet weak var viewEarn: UIView!
    @IBOutlet weak var viewReward: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var referralCount: UILabel!
    @IBOutlet weak var jobsCount: UILabel!
    
    var dictData : ProfileResponseModel?

    
    @IBOutlet weak var copyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavWithOutView(.menu)
        
        self.shadow(codeView)
        self.shadow(viewEarn)
        self.shadow(viewReward)
        shareButton.isEnabled = false
        shareButton.alpha = 0.3
        copyButton.isEnabled = false
        copyButton.alpha = 0.3
        self.getUserData()
        generateInviteLink()
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        shareInviteLink(self.codeLabel.text ?? "")

    }
    @IBAction func copyButtonAction(_ sender: Any) {
        self.copyTextToClipboard(text: self.codeLabel.text ?? "")
    }
    
    func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
    
    func shadow(_ view : UIView)
       {
           view.layer.masksToBounds = false
           view.layer.shadowColor =  UIColor(red: 0.5058823529, green: 0.5333333333, blue: 0.6117647059, alpha: 1).cgColor
           view.layer.shadowOffset = CGSize(width: 0, height: 1)
           view.layer.shadowRadius = 5.0
           view.layer.shadowOpacity = 15.0
           view.layer.cornerRadius = 5.0
       }
    
    func generateInviteLink() {
        AppsFlyerShareInviteHelper.generateInviteUrl(
            linkGenerator: {
                (_ generator: AppsFlyerLinkGenerator) -> AppsFlyerLinkGenerator in
                generator.addParameterValue("", forKey: "deep_link_value")
                generator.addParameterValue("", forKey: "deep_link_sub1")
                generator.addParameterValue(CurrentUserInfo.phone, forKey: "deep_link_sub2")
                generator.addParameterValue(CurrentUserInfo.phone, forKey: "referrer")
                generator.addParameterValue("true", forKey: "af_force_deeplink")
                return generator
            },
            completionHandler: { [self]
                (_ url: URL?) -> Void in
                if url != nil {
                    DispatchQueue.main.async {
                        NSLog("[AFSDK] AppsFlyer share-invite link: \(url!.absoluteString)")

                        if((url?.absoluteString) != nil){
                            self.codeLabel.text = url!.absoluteString
                            self.updateUI()
//                            self.updateInviteCode(url!.absoluteString)
                        }
                    }
                }
                else {
                    print("url is nil")
                }
            }
        )
        
    }
    
    func shareInviteLink(_ inviteLink: String) {
        let message = "Refer this link and earn"
        // Create activity view controller for sharing
        let activityViewController = UIActivityViewController(activityItems: [message, inviteLink], applicationActivities: nil)
        
        // Present the activity view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
//    func updateInviteCode(_ code : String) {
//        
//        var dictParam = [String : Any]()
//        dictParam["inviteLink"] = code
//
//        guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.kUpdateInviteLink.rawValue) else {return}
//        NetworkManager.shared.postRequest(url, false, "", params: dictParam, networkHandler: {(responce,statusCode) in
//            print(responce)
//            APIHelper.parseObject(responce, true) { payload, status, message, code in
//                if status {
//                    self.getUserData()
////                   Alert(title: "Invite Code", message: "Invite code update successfully", vc: self)
//                }
//               
//            }
//        })
//    }
    
    func getUserData() {
        
        let  queryParams = "?getReferralData=true"
        guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.kGetMe.rawValue + queryParams) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    self.dictData =  Mapper<ProfileResponseModel>().map(JSON: payload)
                    CurrentUserInfo.serviceList = self.dictData?.serviceList ?? []
                    self.updateUI()
                }
//                    if(self.dictData?.inviteLink == nil){
//                        self.generateInviteLink()
//                    }
//                    else{
//                        self.updateUI()
//                    }
//                }else{
//                    self.generateInviteLink()
//                }
               
            }
        })
    }
    
    
    func updateUI(){
        referralCount.text = "Total Referrals\n \(self.dictData?.totalReferral ?? 0)"
        jobsCount.text = "Qualified Tows\n \(self.dictData?.totalJobDoneByReferral ?? 0)"
        if(codeLabel.text?.count ?? 0 > 0){
            shareButton.isEnabled = true
            shareButton.alpha = 1.0
            copyButton.isEnabled = true
            copyButton.alpha = 1.0
        }
    }

}
extension UIView {
    func addDottedBorder(color: UIColor, width: CGFloat) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = [2, 2] // Customize the pattern as needed
        shapeLayer.frame = bounds
        shapeLayer.fillColor = nil
        shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        layer.addSublayer(shapeLayer)
    }
}
