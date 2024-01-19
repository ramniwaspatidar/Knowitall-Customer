
import UIKit
import FirebaseAuth
import Firebase

class RequestViewController: BaseViewController,Storyboarded, RTCustomAlertDelegate ,AddressChangeDelegate{
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewRequestType: UIView!
    @IBOutlet weak var situationLabel: UITextView!
    @IBOutlet weak var serviceTypleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var editAddressButton: UIButton!
    @IBOutlet weak var mainBG: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var addAddressButton: UIButton!
    
    var isChecked = true
    
    var username: CustomTextField!
    var name: CustomTextField!
    var mobile: CustomTextField!
    var alertTag = 0
    
    fileprivate let typeOfService = ["Accident","Battery","Fuel","Tow","Lockout","Winch","Flat Tire","Other"]
    
    enum SignupCellType : Int{
        case username = 0
        case name
        case mobile
    }
    
    var viewModel : RequestViewModel = {
        let model = RequestViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavWithOutView(.menu)
        
        serviceTypleLabel.alpha = 1;
        serviceTypleLabel.textColor = UIColor.white
        serviceTypleLabel.text = typeOfService[0]
        
        viewBG.layer.borderWidth = 1
        viewBG.layer.borderColor = UIColor.black.cgColor
        viewBG.layer.cornerRadius = 8
        
        viewRequestType.layer.borderWidth = 1
        viewRequestType.layer.borderColor = UIColor.black.cgColor
        viewRequestType.layer.cornerRadius = 8
        
        situationLabel.text = "Type..."
        situationLabel.textColor = .lightGray
        
        situationLabel.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        setupUI()
    }
    
    // SsetupUI
    fileprivate func setupUI(){
        editAddressButton.isHidden = true
        
        if( CurrentUserInfo.latitude == nil && CurrentUserInfo.longitude == nil){
            addAddressButton.isHidden = false
            addAddressButton.setTitle("Add Address", for: .normal)
        }else{
            addAddressButton.isHidden = true
        }
        SigninCell.registerWithTable(tblView)
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        self.addressLabel.text = viewModel.addressInfo?[6].value
        
        if(viewModel.addressInfo?[6].value == "" || viewModel.addressInfo?[6].value == nil){
            editAddressButton.isHidden = true
        }else{
            editAddressButton.isHidden = false
        }
        
        
        
    }
    
    @IBAction func addAddressAction(_ sender: Any) {
        coordinator?.goToAddressView(addressArray: self.viewModel.addressInfo!,delegate: self)
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        coordinator?.goToAddressView(addressArray: self.viewModel.addressInfo!,delegate: self)
        
    }
    @IBAction func requestButton(_ sender: Any) {
        var temValue = self.viewModel.infoArray[0].value
        let alert = UIAlertController(style: .alert, title: "Service requested", message: "")
        let pickerViewValues: [[String]] = [typeOfService]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: typeOfService.firstIndex(of: self.viewModel.infoArray[0].value) ?? 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            temValue = self.typeOfService[index.row]
        }
        alert.addAction(title: "Done", style: .cancel,handler: { (action:UIAlertAction!) -> Void in
            DispatchQueue.main.async {
                self.viewModel.infoArray[0].value = temValue
                self.serviceTypleLabel.text = temValue
            }
        })
        alert.show()
    }
 
    func addressChangeAction(infoArray: [AddressTypeModel]) {
        self.viewModel.addressInfo = infoArray
        self.editAddressButton.isHidden = true
        self.addressLabel.text = infoArray[6].value
        
        if(viewModel.addressInfo?[6].value == "" || viewModel.addressInfo?[6].value == nil){
            editAddressButton.isHidden = true
        }else{
            editAddressButton.isHidden = false
        }
        self.tblView.reloadData()
        
    }
    
    func onClickSubmit(_ alert: RTCustomAlert, alertTag: Int) {
        if(self.alertTag == 0){
            self.alertTag = 1
            let customAlert = RTCustomAlert()
            customAlert.alertTag = 1
            customAlert.delegate = self
            customAlert.show()
        }
        else if(self.alertTag == 1){
            self.alertTag = 2
            let customAlert = RTCustomAlert()
            customAlert.alertTag = 2
            customAlert.delegate = self
            customAlert.show()
        }else{
            coordinator?.goToTrackingView(self.viewModel.requestData?.requestId ?? "")
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                
                var dictParam = [String : Any]()
                
                let lat = NSString(string: CurrentUserInfo.latitude ?? "0")
                let lng = NSString(string: CurrentUserInfo.longitude ?? "0")
                
                
                dictParam["typeOfService"] = self.viewModel.infoArray[0].value
                dictParam["desc"] = self.viewModel.infoArray[1].value
                dictParam["name"] =  self.viewModel.infoArray[2].value
                dictParam["phoneNumber"] = "\(countryCode)\(self.viewModel.infoArray[3].value)"
                
                dictParam["latitude"] = lat.doubleValue
                dictParam["longitude"] = lng.doubleValue
                dictParam["address"] = self.viewModel.addressInfo?[0].value ?? ""
                dictParam["address1"] = self.viewModel.addressInfo?[1].value ?? ""
                
                dictParam["city"] = self.viewModel.addressInfo?[2].value
                dictParam["state"] = self.viewModel.addressInfo?[3].value
                dictParam["postalCode"] = self.viewModel.addressInfo?[4].value
                dictParam["country"] =  self.viewModel.addressInfo?[5].value
                dictParam["landMark"] =  self.viewModel.addressInfo?[7].value

                
                
                self.viewModel.sendRequest(APIsEndPoints.krequest.rawValue,dictParam, handler: {(response,statusCode)in
                    DispatchQueue.main.async {
                        self.requestView.isHidden = true
                        self.tblView.isHidden = true
                        self.viewModel.requestData = response
                        let customAlert = RTCustomAlert()
                        customAlert.alertTag = 0
                        customAlert.delegate = self
                        customAlert.show()
                        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
                            customAlert.dismissedView()
                        })
                    }
                })
                
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
                }
            }
        }
    }
}
// UITableViewDataSource
extension RequestViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
        
        cell.textFiled.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        switch indexPath.row {
            
        case 0:
            name = cell.textFiled
            name.delegate = self
            name.returnKeyType = .next
            name.text = viewModel.infoArray[2].value
            name.isUserInteractionEnabled = true
            name.autocapitalizationType = .words
            name.autocorrectionType = .no
            
            
        case 1:
            mobile = cell.textFiled
            mobile.delegate = self
            mobile.returnKeyType = .next
            mobile.text = viewModel.infoArray[3].value
            mobile.keyboardType = .phonePad
            
        default:
            break
        }
        
        cell.commiInit(viewModel.infoArray[indexPath.row + 2])
        
        return cell
    }
}

extension RequestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension RequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == username{
            name.becomeFirstResponder()
        }
        else   if textField == name{
            name.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = tblView.convert(textField.bounds.origin, from: textField)
        let index = tblView.indexPathForRow(at: point)
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row ?? 0) + 2].value = str ?? ""
        
        return true
    }
}

extension RequestViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type..."
            textView.textColor = UIColor.white
        }
        self.viewModel.infoArray[1].value = textView.text
    }
}



