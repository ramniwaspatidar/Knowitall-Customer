

import UIKit
import FirebaseAuth
import OTPFieldView
import FirebaseMessaging
import SVProgressHUD

class OTPViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    var verificationID : String?
    var mobileNumber : String?
    var countdownTimer: Timer!
    var totalTime = 30
    var varificationCode : String = ""
    @IBOutlet weak var headerText: UILabel!
    
    
    @IBOutlet var otpTextFieldView: OTPFieldView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(.back, self.view)
        
        headerText.text = "We have sent a verification code to +91 \(mobileNumber ?? ""), please enter below to verify and continue "
        setupOtpView()
    }
    
    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 6
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.defaultBorderColor = UIColor.black
        self.otpTextFieldView.filledBorderColor = UIColor.black
        self.otpTextFieldView.cursorColor = UIColor.black
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
    
    @IBAction func otpVerifyButton(_ sender: Any) {
        
        if(self.varificationCode.count > 5){
            self.verifyOTP(varificationCode)
        }else{
            Alert(title: "", message: "Invalid verification code", vc: RootViewController.controller!)
        }
    }
    
    func verifyOTP(_ code : String){
        
        
        SVProgressHUD.show()
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID!, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                SVProgressHUD.dismiss()

                let authError = error as NSError
                Alert(title: "", message: "Invalid verification code", vc: RootViewController.controller!)
                return
            }
            
            
            if let user = authResult?.user {
                // Get the Firebase ID token (access token)
                user.getIDTokenForcingRefresh(true) { (idToken, error) in
                    if let error = error {
                        SVProgressHUD.dismiss()

                        print("Error getting ID token: \(error.localizedDescription)")
                        Alert(title: "", message: "Invalid verification token", vc: RootViewController.controller!)
                        
                        
                        return
                    }
                    if let accessToken = idToken {
                        var dictParam = [String : String]()
                        dictParam["countryCode"] = "+91"
                        dictParam["phoneNumber"] = self.mobileNumber
                        
                        self.verifyOTP(APIsEndPoints.ksignupUser.rawValue,dictParam, handler: {(mmessage,statusCode)in
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()

                                CurrentUserInfo.phone = self.mobileNumber
                                Messaging.messaging().subscribe(toTopic: CurrentUserInfo.userId) { error in
                                    
                                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                    appDelegate?.autoLogin()

                                    if let error = error {
                                        print("Error subscribing from topic: \(error.localizedDescription)")
                                    } else {
                                        print("Successfully subscribed from topic!")


                                    }
                                }
                            
                            }
                        })
                        
                    }
                }
            }
        }
    }
    
    func verifyOTP(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    
                    let customerId = payload["customerId"] as? String
                    let number = payload["fullNumber"] as? String
                    CurrentUserInfo.userId = customerId
                    CurrentUserInfo.phone = number
                    
                    handler(message,0)
                    
                }
                else{
                    DispatchQueue.main.async {
                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }
    
}

extension OTPViewController: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        
        self.varificationCode = otpString
        print("OTPString: \(otpString)")
    }
}



