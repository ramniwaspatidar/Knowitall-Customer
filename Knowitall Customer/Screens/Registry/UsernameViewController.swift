

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UsernameViewController: UIViewController,Storyboarded {

    var coordinator: MainCoordinator?
    var mobileTextField: CustomTextField!
    var database : Firestore?
    
    fileprivate lazy var viewModel : UserNameModel = {
        let viewModel = UserNameModel()
        return viewModel }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = Firestore.firestore()
        
        // MARK : Initial setup
        UISetup()
    }
    private func UISetup(){
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
      
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func loginButtonAction(_ sender: Any) {
        
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = dict["username"] as? String
                changeRequest?.commitChanges { error in
                    
                    if((error) != nil){
                        Alert(title: error?.localizedDescription ?? "", message: msg, vc: self)
                    }else
                    {
                        self.checkExistUser()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "Enter mobile number", message: msg, vc: self)
                }
            }
        }
    }
    
    
    
    private func addUserName(userId : String){
        
        let updateUserDetails = database?.collection("users").document("\(userId)")
        updateUserDetails?.updateData([
            "username": mobileTextField.text as Any
        ]) { err in
            if let err = err {
                Alert(title: "Error", message: "Error updating document: \(err)", vc: self)
            } else {
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.autoLogin()
                }
            }
        }
        
    }
    
    private func checkExistUser(){
        let userId  = Auth.auth().currentUser?.uid ?? ""
        
        let query = database?.collection("users").whereField("username", isEqualTo: mobileTextField.text as Any);
        
        query?.getDocuments { (snapshot, err) in
            if err != nil {
                Alert(title: "Error", message: "Error updating document", vc: self)
            } else {
                var isExist = false
                
                for document in snapshot!.documents {
                    
                    if(document.exists){
                        isExist = true
                    }
                }
                if(!isExist){
                    self.addUserName(userId: userId)
                }else{
                    Alert(title: "Username Exist", message: "Username already exist, Try with diffrent username", vc: self)
                }
            }
        }
    }
    
    func validedUserName() {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.viewModel.infoArray[0].isValided = true
//                self.submitButton.alpha = 1
            }
            else {
                self.viewModel.infoArray[0].isValided = false
//                self.submitButton.isUserInteractionEnabled = false
//                self.submitButton.alpha = 0.4
            }
        }
    }
    @objc func signupAction(gesture: UITapGestureRecognizer) {
//        if let range = kTC.range(of: kTC),gesture.didTapAttributedTextInLabel(label: signupLabel, inRange: NSRange(range, in: kTC)) {
//            coordinator?.goToWebview(type: WebViewType.TC)
//        }else  if let range = kTC.range(of: kRegisterNow),gesture.didTapAttributedTextInLabel(label: signupLabel, inRange: NSRange(range, in: kTC)) {
//            coordinator?.goToWebview(type: WebViewType.policy)
//        }
    }
    
    @objc func selectFlagtAction(gesture: UITapGestureRecognizer) {
        
    }
    
}




