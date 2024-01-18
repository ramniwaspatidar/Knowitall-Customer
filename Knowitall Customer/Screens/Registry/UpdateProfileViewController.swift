

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
    
    var isImageChanged = false
    
    var profileImageUrl = ""

    
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
        
        if CurrentUserInfo.phone.count == 10 {
            
            let digits = CurrentUserInfo.phone ?? ""
            let formattedNumber = String(format: "%@-%@-%@",
                                String(digits.prefix(4)),
                                          String(digits.dropFirst(4).prefix(3)),
                                          String(digits.dropFirst(7)))
            emailLabel.text = "+1 \(formattedNumber)"

            }
        else{
            emailLabel.text = "+1 \( CurrentUserInfo.phone ?? "")"

        }
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        nameTextField.clipsToBounds = true
        nameTextField.text = viewModel.dictData?.name ?? CurrentUserInfo.userName
        nameTextField.layer.cornerRadius = 5
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        nameTextField.keyboardType = .default
        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no
        
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        emailTextField.clipsToBounds = true
        emailTextField.text = viewModel.dictData?.email ?? CurrentUserInfo.email
        emailTextField.layer.cornerRadius = 5
        emailTextField.keyboardType = .emailAddress
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        if((self.viewModel.dictData?.profileImage) != nil){
            self.profileImageUrl =  self.viewModel.dictData?.profileImage  ?? ""
            self.profileImage.load(url:URL(string: self.viewModel.dictData?.profileImage ?? "")!)
        }
        
    }
    
    
    @IBAction func chooseProfileAction(_ sender: Any) {
            ImagePickerManager().pickImage(self){ image in
                self.isImageChanged = true
                self.profileImage.image = image
        }
    }
    
    func getProfileImageUploadUrl(_ img : UIImage){
        self.viewModel.getProfileUploadUrl(APIsEndPoints.kUploadImage.rawValue, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                self?.uploadImage(result, img.jpegData(compressionQuality: 0.7)!, _contentType: "image/jpeg")
            }
        })
    }
  
    
    func uploadImage(_ thumbURL:String, _ thumbnail:Data,_contentType:String){
            let requestURL:URL = URL(string: thumbURL)!
            NetworkManager.shared.imageDataUploadRequest(requestURL, HUD: true, showSystemError: false, loadingText: false, param: thumbnail, contentType: _contentType) { (sucess, error) in
                print("thumbnail image")
                if (sucess ?? false) == true{
                    let temp = thumbURL.split(separator: "?")
                    if let some = temp.first {
                        let value = String(some)
                        self.profileImageUrl = value
                        self.updateUserInfo()

                    }
                }
            }
                      
        }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                if(self.isImageChanged){
                    self.getProfileImageUploadUrl(self.profileImage.image!)
                }else{
                    self.updateUserInfo()
                }
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
            var dictParams = dict
            if(self.isImageChanged){
                dictParams["profileImage"] = self.profileImageUrl as AnyObject
            }
            if isSucess {
                self.viewModel.updateProfile(APIsEndPoints.ksignupUser.rawValue,dictParams, handler: {[weak self](result,statusCode)in
                    if statusCode ==  0{
                        DispatchQueue.main.async {
                            CurrentUserInfo.userId = result.customerId
                            CurrentUserInfo.userName = result.name
                            CurrentUserInfo.email = result.email
                            CurrentUserInfo.phone = "\(result.phoneNumber ?? "0")"
                            self?.isImageChanged = false
                            Alert(title: "Update", message: "Profile susscessfully updated", vc: self!)
                        }
                    }
                })
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



extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
