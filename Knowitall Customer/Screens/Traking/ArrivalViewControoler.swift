
import UIKit
import FirebaseAuth
import Firebase
//import FirebaseDatabase
//import FirebaseFirestore
import OTPFieldView

class ArrivalViewControoler: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var arrivalButton: UIView!
    @IBOutlet var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var headingText: UILabel!
    
    @IBOutlet weak var headingTextHeight: NSLayoutConstraint!
    var dictRequest : RequestListModal?
    var arrivalCode : String = ""
    
    
    var viewModel : ArrivalViewModal = {
        let model = ArrivalViewModal()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(ButtonType.back)
        setupOtpView()
        
        bgView.isHidden = true
        animationView.isHidden = true
        confirmView.isHidden = true
        
        
        var  address = ""
        
        if((self.dictRequest?.latitude) != nil){
            address =  "Please confirm your destination address and input the Verification Code from the driver. Onces received, enter the code to proceed. \n\n" +  "Address: \(self.dictRequest?.destinationAdd?.address ?? "") \(self.dictRequest?.destinationAdd?.address1 ?? ""), \(self.dictRequest?.destinationAdd?.city ?? ""), \(self.dictRequest?.destinationAdd?.state ?? ""), \(self.dictRequest?.destinationAdd?.country ?? "") - \(self.dictRequest?.destinationAdd?.postalCode ?? "")"
            headingTextHeight.constant = 250
        }else{
            address = "Ask the Driver for the Arrival Code and enter to confirm please."
        }
        
        headingText.text = address
        
        
    }
    
    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 4
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.filledBorderColor = hexStringToUIColor("FF004F")
        self.otpTextFieldView.defaultBorderColor = .black
        self.otpTextFieldView.cursorColor =  .black
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
        self.otpTextFieldView.backgroundColor = .white
        self.otpTextFieldView.tintColor = .white
        
    }
    
    @IBAction func arrivalButtonAction(_ sender: Any) {
        self.getConfirmArrival()
    }
    
    func getConfirmArrival(){
        
        self.bgView.isHidden = false
        self.animationView.isHidden = false
        self.confirmView.isHidden = true
        
        var param = [String : Any]()
        param["arrivalCode"] = arrivalCode
        
        viewModel.confirmArrival(APIsEndPoints.kConfirmArrival.rawValue + (dictRequest?.requestId ?? ""), param,hud: true) { response, code in
            
            if(code == 0){
                self.animationView.isHidden = true
                self.confirmView.isHidden = false
                self.bgView.isHidden = true
            }else{
                self.animationView.isHidden = true
                self.confirmView.isHidden = true
                self.bgView.isHidden = true
                self.otpView.isHidden = false
            }

        }
    }
    
    @IBAction func thanksButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
extension ArrivalViewControoler: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        
        self.arrivalCode = otpString
    }
}
