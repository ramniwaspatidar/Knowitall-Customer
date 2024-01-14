
import Foundation
import UIKit
import ObjectMapper


enum UpdateProfileFiledType {
    case name
    case email
    
}
struct UpdateProfileInfoModel{
    var type : UpdateProfileFiledType
    var placeholder : String
    var value : String
    var header : String
    
    init(type: UpdateProfileFiledType, placeholder: String , value: String,header: String) {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header
        
    }
}

class UpdateProfileViewModal {
    var dictInfo = [String : String]()
    var infoArray = [UpdateProfileInfoModel]()
    var dictData : ProfileResponseModel?
    var isUpdate : Bool = false
    var userNotExist : Bool = false
    
    var hintImageView: UIImageView!
    var hintImageWidth: NSLayoutConstraint!
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : ProfileResponseModel)-> [UpdateProfileInfoModel]{
        infoArray.append(UpdateProfileInfoModel(type: .name, placeholder: "Enter", value: dictInfo.fullName ?? "", header: "Enter Name"))
        
        infoArray.append(UpdateProfileInfoModel(type: .email, placeholder: "Enter", value: dictInfo.phoneNumber ?? "", header: "Email Number"))
        
        return infoArray
    }
    
    func validateFields(dataStore: [UpdateProfileInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
                
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""  {
                    validHandler([:],NSLocalizedString(LanguageText.name.rawValue, comment: ""), false)
                    return
                }
                dictParam["name"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .email:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""{
                    validHandler([:], NSLocalizedString(LanguageText.email.rawValue, comment: ""), false)
                    return
                }
                dictParam["email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    
    
    
}
