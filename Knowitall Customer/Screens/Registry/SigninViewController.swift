

import UIKit
import FirebaseAuth
import SideMenu
import SVProgressHUD
class SigninViewController: UIViewController,Storyboarded  {
   
    
   
    var coordinator: MainCoordinator?
    var currentVerificationId = ""
    
    @IBOutlet weak var signInTablView: UITableView!
    @IBOutlet weak var termsLabel: CustomLabel!
    @IBOutlet weak var vieweCountryCode: UIView!
    @IBOutlet weak var mobileField: CustomTextField!
    
    fileprivate lazy var viewModel : SigninViewModel = {
        let viewModel = SigninViewModel()
        return viewModel }()
    
 
    override func viewDidLoad() {
        
        SideMenuManager.default.leftMenuNavigationController = nil
        
        super.viewDidLoad()
        UISetup()
    }
    private func UISetup(){
        
        vieweCountryCode.layer.borderWidth = 1
        vieweCountryCode.layer.borderColor = UIColor.black.cgColor
        vieweCountryCode.layer.cornerRadius = 8
        
        mobileField.layer.borderWidth = 1
        mobileField.layer.borderColor = UIColor.black.cgColor
        mobileField.layer.cornerRadius = 8
        
        mobileField.becomeFirstResponder()
        
        mobileField.delegate = self;
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        
    }
 
    
    @IBAction func menuButtonAction(_ sender: Any) {
        let menu1 = storyboard!.instantiateViewController(withIdentifier: "RightMenu") as! SideMenuNavigationController
        let menu = SideMenuNavigationController(rootViewController: menu1)
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func OTPRequestAction(_ sender: Any) {
        
        let str =  self.mobileField.text ?? ""
        
        SVProgressHUD.show()
        
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                PhoneAuthProvider.provider().verifyPhoneNumber("+91\(str)" , uiDelegate: nil) { (verificationID, error) in
                    SVProgressHUD.dismiss()

                    if let error = error {
                        print(error.localizedDescription)
                        Alert(title: "Alert", message: "Invalid phone number +91\(str) \(error.localizedDescription)" , vc: self)

                        return
                    }
                    guard let temId = verificationID else {return }
                    self.coordinator?.goToOTP(temId,self.mobileField.text ?? "")
                }
            }
            else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    Alert(title: "Alert", message: msg, vc: self)
                }
            }
        }
    }
    
}


extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        if textField == mobileField{
            mobileField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[0].value = str ?? ""
        viewModel.infoArray[0].isValided = false

        return true
    }
}



