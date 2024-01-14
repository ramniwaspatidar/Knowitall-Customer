

import UIKit
import FirebaseAuth
import OTPFieldView
import FirebaseMessaging
import SVProgressHUD
import ObjectMapper

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
        self.setNavWithOutView(.back)
        
        headerText.text = "We have sent a verification code to \(countryCode) \(mobileNumber ?? ""), please enter below to verify and continue "
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
    
    @IBAction func resendCodeAction(_ sender: Any) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber("\(countryCode)\(mobileNumber ?? "")" , uiDelegate: nil) { (verificationID, error) in
            SVProgressHUD.dismiss()

            if let error = error {
                print(error.localizedDescription)
                Alert(title: "Alert", message: "Invalid phone number \(countryCode)\(self.mobileNumber ?? "") \(error.localizedDescription)" , vc: self)
                return
            }else{
                guard let temId = verificationID else {return }
                self.verificationID = temId
                Alert(title: "Resend OTP", message: "OTP successfully send", vc: self)
                
            }
        }

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
                Alert(title: "", message: "Invalid verification code", vc: RootViewController.controller!)
                return
            }
            
            
            if let user = authResult?.user {
                
                self.getUserData()

                
            }
        }
    }
    
        
    func getUserData() {
        guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.kGetMe.rawValue) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<ProfileResponseModel>().map(JSON: payload)
                    
                    CurrentUserInfo.userId = dictResponce?.customerId
                    CurrentUserInfo.phone = self.mobileNumber
                    CurrentUserInfo.userName  = dictResponce?.fullName
                    CurrentUserInfo.email  = dictResponce?.email

                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.autoLogin()
                }
                else{
                    
                    if(payload["code"] as? Int == 101){ // move to profile
                        self.coordinator?.goToProfile(self.mobileNumber ?? "")

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



