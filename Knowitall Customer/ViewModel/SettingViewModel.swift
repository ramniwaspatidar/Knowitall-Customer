
import Foundation
import UIKit
import ObjectMapper



struct SettingModel{
    var image: UIImage!
    var placeholder : String
    var name : String

    init(image: UIImage , placeholder: String = "", name: String = "") {
        self.image = image
        self.name = name
        self.placeholder = placeholder

    }
}

class SettingViewModel {
    var dictInfo = [String : String]()
    var settingArray = [SettingModel]()
    
    
    func prepareInfo() -> [SettingModel] {
        
        settingArray.append(SettingModel( image: UIImage(named: "home")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Home"))
        
        settingArray.append(SettingModel( image: UIImage(named: "truck_black")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "My Help Requests"))
        
        settingArray.append(SettingModel( image: UIImage(named: "account")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "My Account"))
        
        settingArray.append(SettingModel( image: UIImage(named: "call")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Call Directly"))
        
        settingArray.append(SettingModel( image: UIImage(named: "gift")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Refer & Earn"))
        
        settingArray.append(SettingModel( image: UIImage(named: "privacy")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "T&C"))
        
        settingArray.append(SettingModel( image: UIImage(named: "faq")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "FAQ's"))
        settingArray.append(SettingModel( image: UIImage(named: "delete")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Delete Account"))
        
        settingArray.append(SettingModel( image: UIImage(named: "logout")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Sign Out"))
        
                
        return settingArray;
        
    }
    func deleteAccount(_ apiEndPoint: String, handler: @escaping (String,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.deleteRequest(url, true, "", networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    handler(message,0)
                }
                else{
                    handler(message,-1)
                }
            }
        })
    }

}
