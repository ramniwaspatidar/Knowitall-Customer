

import UIKit
import ObjectMapper
class UpdateProfileViewController: BaseViewController,Storyboarded {
    
    @IBOutlet weak var tblView: UITableView!
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numberHeader: UILabel!
    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var nameTextField: CustomTextField!
    
      var viewModel : UpdateProfileViewModal = {
        let viewModel = UpdateProfileViewModal()
        return viewModel }()

    enum ProfileCellType : Int{
        case name = 0
        case email
    }
    
    
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(.menu)
        self.UISetup()
        
        self.getUserData()
    }
    
    func getUserData() {
        guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.kGetMe.rawValue) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    self.viewModel.dictData =  Mapper<ProfileResponseModel>().map(JSON: payload)
                    self.viewModel.infoArray = self.viewModel.prepareInfo(dictInfo: self.viewModel.dictData!)
                    self.UISetup()
                }
               
            }
        })
    }

    

    
    private func UISetup(){
        
        emailLabel.text = CurrentUserInfo.email ?? ""
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        nameTextField.clipsToBounds = true
        nameTextField.text = viewModel.dictData?.fullName ?? CurrentUserInfo.userName
        nameTextField.layer.cornerRadius = 5
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        emailTextField.clipsToBounds = true
        emailTextField.text = viewModel.dictData?.email ?? CurrentUserInfo.email
        emailTextField.layer.cornerRadius = 5
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
 
        
    }
    
    
    @IBAction func chooseProfileAction(_ sender: Any) {
        
            ImagePickerManager().pickImage(self){ image in
                self.profileImage.image = image
            
        }
    }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.updateUserInfo()
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
                }
            }
        }
    }
    

    
    func updateUserInfo() {

        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            
            if isSucess {
//                self.updateProfileModal.updateProfile(APIsEndPoints.ksignupUser.rawValue,dict, handler: {[weak self](result,statusCode)in
//                    if statusCode ==  0{
//                        DispatchQueue.main.async {
//                            CurrentUserInfo.userId = result.driverId
//                                CurrentUserInfo.userName = result.fullName
//                                CurrentUserInfo.email = result.email
//                                CurrentUserInfo.phone = "\(countryCode) \(self?.emailTextField.text ?? "0")"
//                            Alert(title: "Update", message: "Profile susscessfully updated", vc: self!)
//
//                                                        
//                        }
//                    }
//                })
             }
             else {
             Alert(title: "", message: msg, vc: self)
             }
        }
   }
}



extension UpdateProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        }
        else if textField == emailTextField{
            emailTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if textField == nameTextField {
            viewModel.infoArray[0].value = str ?? ""
        }
     
        else if textField == emailTextField{
            viewModel.infoArray[1].value = str ?? ""
        }
        
        return true
    }
}



