
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class AddressViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewRequestType: UIView!
    @IBOutlet weak var landmarkTextView: UITextView!
    @IBOutlet weak var serviceTypleLabel: UILabel!

    var addressField1: CustomTextField!
    var addressField2: CustomTextField!
    var cityField: CustomTextField!
    var stateField: CustomTextField!
    var landMarkField: CustomTextField!

    fileprivate let typeOfService = ["Accident","Emergency","Help"]
    
    enum AddressCellType : Int{
        case address1 = 0
        case address2
        case city
        case state
        case landmark
    }
    
    var viewModel : AddressViewModel = {
        let model = AddressViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        landmarkTextView.layer.borderWidth = 1
        landmarkTextView.layer.borderColor = UIColor.black.cgColor
        landmarkTextView.layer.cornerRadius = 8
        landmarkTextView.text = "Type..."
        
        setupUI()
    }
    
    // SsetupUI
    fileprivate func setupUI(){
        SigninCell.registerWithTable(tblView)
//        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
    }
    
    func stateActionButton() {
        RPicker.selectOption(dataArray: typeOfService) { [weak self](str, selectedIndex) in
            self?.viewModel.infoArray[3].value = str
            self?.tblView.reloadData()
        }
    }
  
    @IBAction func saveButtonAction(_ sender: Any) {
        
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.navigationController?.popViewController(animated: false)
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
extension AddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
        
        switch indexPath.row {
       
        case 0:
            addressField1 = cell.textFiled
            addressField1.delegate = self
            addressField1.returnKeyType = .next
            addressField1.text = viewModel.infoArray[0].value
            addressField1.isUserInteractionEnabled = true
            
        case 1:
            addressField2 = cell.textFiled
            addressField2.delegate = self
            addressField2.returnKeyType = .next
            addressField2.text = viewModel.infoArray[1].value
            addressField2.keyboardType = .numberPad
        
        case 2:
            cityField = cell.textFiled
            cityField.delegate = self
            cityField.returnKeyType = .next
            cityField.text = viewModel.infoArray[2].value
            cityField.keyboardType = .numberPad
            
        case 3:
            stateField = cell.textFiled
            stateField.isUserInteractionEnabled = false
            stateField.delegate = self
            stateField.returnKeyType = .next
            stateField.text = viewModel.infoArray[3].value
            stateField.keyboardType = .numberPad
            
        default:
            break
        }
        
        cell.commiAddressInit(viewModel.infoArray[indexPath.row])
        
        return cell
    }
}

extension AddressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if (indexPath.row == 3){
            self.stateActionButton()
        }
    }
}

extension AddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == addressField1{
            addressField2.becomeFirstResponder()
        }
        
       else if textField == addressField2{
            cityField.becomeFirstResponder()
        }
        else if textField == cityField{
            stateField.becomeFirstResponder()
        }
        else   if textField == stateField{
            stateField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = tblView.convert(textField.bounds.origin, from: textField)
        let index = tblView.indexPathForRow(at: point)
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[index?.row ?? 0].value = str ?? ""
        
        return true
    }
}

extension AddressViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .white
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type..."
            textView.textColor = UIColor.white
        }
        self.viewModel.infoArray[4].value = textView.text
    }
}



