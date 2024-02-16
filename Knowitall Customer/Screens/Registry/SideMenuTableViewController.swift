import UIKit
import FirebaseAuth
import SideMenu
import FirebaseMessaging
import Branch
import AppsFlyerLib


class SideMenuTableViewController: UIViewController, Storyboarded  {
    
    var coordinator: MainCoordinator?
    
    var tableView: UITableView!
    
    lazy var viewModel : SettingViewModel = {
        let viewModel = SettingViewModel()
        return viewModel }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = hexStringToUIColor("F7D63D")
        viewModel.settingArray =  viewModel.prepareInfo()
        // Initialize and configure the UITableView
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register a UITableViewCell class or reuse identifier if needed
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        // Add the UITableView to the view hierarchy
        view.addSubview(tableView)
        
        // Set up constraints (you can customize these according to your layout)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        SettingCell.registerWithTable(tableView)
        
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit // Adjust content mode as needed
        imageView.frame = CGRect(x: (view.frame.width - 175)/2, y: 0, width: 175, height: 175)
        tableView.tableHeaderView = imageView
        
        
        let button = UIButton(frame: CGRect(x: 20, y: 100, width: 200, height: 60))
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        //        button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        //        tableView.tableFooterView = button
    }
    
    func buttonTapped() {
        
        do{
            try Auth.auth().signOut()
            
            Messaging.messaging().unsubscribe(fromTopic: CurrentUserInfo.userId) { error in
                if let error = error {
                    print("Error unsubscribing from topic: \(error.localizedDescription)")
                } else {
                    print("Successfully unsubscribed from topic!")
                }
            }
            
            CurrentUserInfo.email = nil
            CurrentUserInfo.phone = nil
            CurrentUserInfo.language = nil
            CurrentUserInfo.location = nil
            CurrentUserInfo.userId = nil
            
            let menu = SideMenuManager.default.leftMenuNavigationController
            menu?.enableSwipeToDismissGesture = false
            
            menu?.dismiss(animated: false, completion: {
                let  appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.autoLogin()
            })
            
        }catch{
            
        }
        
    }
    func deleteUserAccount(){
        self.viewModel.deleteAccount(APIsEndPoints.ksignupUser.rawValue , handler: {[weak self](message,statusCode)in
            
            if(statusCode == 0){
                self?.buttonTapped()
            }else{
                Alert(title: "Error", message: message, vc: self!)
            }
            
        })

    }

    
}

extension SideMenuTableViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier, for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        
        cell.commonInit(viewModel.settingArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coordinator =  appDelegate?.coordinator
//        coordinator = MainCoordinator(navigationController: self.navigationController!)
        var isDismiss = true
        
        if(indexPath.row == 0){
            coordinator?.goToHelpView()
            
        }else if(indexPath.row == 1){
            coordinator?.goToRequest()
            
        }
        else if(indexPath.row == 2){ /// my account
            coordinator?.goToUpdateProfile()
        }
        else if(indexPath.row == 3){
            guard let url = URL(string: "telprompt://\(countryCode)2406791043"),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else if(indexPath.row == 4){// promo code            

//            let customParams = [
//                "referral_code": CurrentUserInfo.phone,
//                // Other custom parameters if needed
//            ]
//
//            Branch.getInstance().getShortURL(withParams: customParams as [AnyHashable : Any]) { (url, error) in
//                if let error = error {
//                    print("Error creating invite link: \(error.localizedDescription)")
//                } else if let url = url {
//                    print("Invite link created: \(url)")
//                    // Use the invite link as needed
//                }
//            }
            
            generateInviteLink()
        }
        else if(indexPath.row == 5){
            coordinator?.goToWebview(type: .TC)

        }
        else if(indexPath.row == 6){
            coordinator?.goToWebview(type: .FAQ)
        }
        else if(indexPath.row == 7){
            isDismiss = false
            showInputDialog(title: "Delete Account",
                            subtitle: "Before proceeding with account deletion, We need to verify your phone number. Please enter you phone number",
                            actionTitle: "Delete Account",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Enter phone number",
                            inputKeyboardType: .phonePad, actionHandler:
                                    { (input:String?) in
                
                
                if(input != "" &&  input == CurrentUserInfo.phone){
                    self.deleteUserAccount()
                    
                }else{
                    Alert(title: "Error", message: "Enter valid phone number", vc: self)
                }
            })
        }

        else if(indexPath.row  == 8){
            isDismiss = false
            let  appDelegate = UIApplication.shared.delegate as? AppDelegate
            AlertWithAction(title:"Sign out", message: "Are you sure that you want to Sign out from app?", ["Yes, Sign out","No"], vc: self, kAlertRed) { [self] action in
                if(action == 1){
                    self.buttonTapped()
                }
            }
        }
        
        
        if(isDismiss){
            dismiss(animated: true, completion: nil)
            
        }
    }
    func generateInviteLink() {
        AppsFlyerShareInviteHelper.generateInviteUrl(
            linkGenerator: {
                (_ generator: AppsFlyerLinkGenerator) -> AppsFlyerLinkGenerator in
                generator.addParameterValue("", forKey: "deep_link_value")
                generator.addParameterValue("", forKey: "deep_link_sub1")
                generator.addParameterValue(CurrentUserInfo.phone, forKey: "deep_link_sub2")
                //                    // Optional; makes the referrer ID available in the installs raw-data report
                //                    generator.addParameterValue(<REFERRER_ID>, forKey: "af_sub1")
                //                    generator.setCampaign("summer_sale")
                //                    generator.setChannel("mobile_share")
                //                      // Optional; Set a branded domain name:
                //                      generator.brandDomain = "brand.domain.com"
                return generator
            },
            completionHandler: { [self]
                (_ url: URL?) -> Void in
                if url != nil {
                    NSLog("[AFSDK] AppsFlyer share-invite link: \(url!.absoluteString)")
                    shareInviteLink(url!.absoluteString)
                }
                else {
                    print("url is nil")
                }
            }
        )
        
    }
        
        // Function to share invite link
        func shareInviteLink(_ inviteLink: String) {
            // Create activity view controller for sharing
            let activityViewController = UIActivityViewController(activityItems: [inviteLink], applicationActivities: nil)
            
            // Present the activity view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
}
extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
