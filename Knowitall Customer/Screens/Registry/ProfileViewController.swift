

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseMessaging
import SideMenu

class ProfileViewController: BaseViewController,Storyboarded {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var lblReferredBy: UILabel!
    @IBOutlet weak var constraintReferredByHeight: NSLayoutConstraint!
    
    var coordinator: MainCoordinator?
    var emailTextField: CustomTextField!
    var nameTextField: CustomTextField!
    
    var viewModel : ProfileViewModel = {
        let viewModel = ProfileViewModel()
        return viewModel }()
    
    
    
    enum SigninCellType : Int{
        case name = 0
        case email
    }
    fileprivate let passwordCellHeight = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.default.leftMenuNavigationController = nil
        //        self.setNavWithOutView(.back)
        // MARK : Initial setup
        UISetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(UserDefaults.standard.bool(forKey: "developer_mode") )
        {
            lblReferredBy.isHidden = false
            constraintReferredByHeight.constant = 24
            if let stringValue = UserDefaults.standard.string(forKey: "referralCode") {
                lblReferredBy.text = "Referred By :- \(stringValue)"
            }
        }
        else{
            lblReferredBy.isHidden = true
            constraintReferredByHeight.constant = 0
        }
    }
    
    private func UISetup(){
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        UserNameCell.registerWithTable(tblView)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.createUser()
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
                }
            }
        }
    }
    
    
    func createUser(){
        
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            var dictParam = [String : String]()
            dictParam["countryCode"] = countryCode
            dictParam["phoneNumber"] = self.viewModel.mobileNumber
            dictParam["email"] = self.emailTextField.text
            dictParam["name"] = self.nameTextField.text
            
            if let stringValue = UserDefaults.standard.string(forKey: "referralCode") {
                dictParam["referredBy"] = stringValue
            }
            
            self.updateProfile(APIsEndPoints.ksignupUser.rawValue,dictParam, handler: {(mmessage,statusCode)in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    CurrentUserInfo.phone = self.viewModel.mobileNumber
                    CurrentUserInfo.userName  = self.nameTextField.text
                    CurrentUserInfo.email  = self.emailTextField.text
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.autoLogin()
                    
                }
            })
            
        }
    }
    
    func updateProfile(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let customerId = payload["customerId"] as? String
                    let number = payload["fullNumber"] as? String
                    CurrentUserInfo.userId = customerId
                    CurrentUserInfo.phone = number
                    CurrentUserInfo.email = self.emailTextField.text
                    CurrentUserInfo.userName = self.nameTextField.text
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



// UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: UserNameCell.reuseIdentifier, for: indexPath) as! UserNameCell
        cell.selectionStyle = .none
        
        
        switch indexPath.row {
            
        case SigninCellType.name.rawValue:
            nameTextField = cell.textFiled
            nameTextField.delegate = self
            nameTextField.autocapitalizationType = .words
            nameTextField.autocorrectionType = .no
            nameTextField.keyboardType = .default
            nameTextField.returnKeyType = .next
            
        case SigninCellType.email.rawValue:
            
            emailTextField = cell.textFiled
            emailTextField.keyboardType = .emailAddress
            emailTextField.delegate = self
            emailTextField.returnKeyType = .done
            
        default:
            break
        }
        
        cell.commiInit(viewModel.infoArray[indexPath.row])
        
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(passwordCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextField {
            nameTextField.becomeFirstResponder()
        }
        else if textField == nameTextField{
            nameTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = tblView.convert(textField.bounds.origin, from: textField)
        let index = tblView.indexPathForRow(at: point)
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row)!].value = str ?? ""
        
        return true
    }
}



