
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
    
    var dictRequest : RequestListModal?
    var arrivalCode : String = ""
    
    
    var viewModel : ArrivalViewModal = {
        let model = ArrivalViewModal()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(ButtonType.back,otpView)
        setupOtpView()
        
        bgView.isHidden = true
        animationView.isHidden = true
        confirmView.isHidden = true
        
        
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
        
        viewModel.confirmArrival(APIsEndPoints.kConfirmArrival.rawValue + (dictRequest?.requestId ?? ""), param) { response, code in
            self.animationView.isHidden = true
            self.confirmView.isHidden = false
            self.bgView.isHidden = true
        }
    }
    
    @IBAction func thanksButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
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
