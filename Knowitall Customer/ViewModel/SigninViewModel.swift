
import Foundation
import UIKit
import ObjectMapper

class SigninViewModel {
    var dictInfo = [String : String]()
    var infoArray = [SigninInfoModel]()
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : [String :String])-> [SigninInfoModel]  {
        
        infoArray.append(SigninInfoModel(type: .number, image: UIImage(named: "profilePlaceholder") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), value: "", countryCode: "", header: "",selected: false, isValided:false))
        
        return infoArray
    }
    
    func validateFields(dataStore: [SigninInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .number:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],NSLocalizedString(LanguageText.number.rawValue, comment: ""), false)
                    return
                }
//                else  if dataStore[index].countryCode.trimmingCharacters(in: .whitespaces) == "" {
//                    validHandler([:],NSLocalizedString(LanguageText.countryCode.rawValue, comment: ""), false)
//                    return
//                }
                else  if dataStore[index].value.trimmingCharacters(in: .whitespaces).count  < 6 || dataStore[index].value.trimmingCharacters(in: .whitespaces).count  > 12 {
                    validHandler([:],NSLocalizedString(LanguageText.inValideNumber.rawValue, comment: ""), false)
                    return
                }
                dictParam["number"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            }
        }
        validHandler(dictParam, "", true)
    }
   
}
