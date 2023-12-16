
import Foundation
import UIKit
import ObjectMapper

class UserNameModel {
    var dictInfo = [String : String]()
    var infoArray = [SigninInfoModel]()
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : [String :String])-> [SigninInfoModel]  {
        
        infoArray.append(SigninInfoModel(type: .number, image: UIImage(named: "profilePlaceholder") ??  #imageLiteral(resourceName: "img4"), placeholder: NSLocalizedString(LanguageText.username.rawValue, comment: ""), value: "", countryCode: "", header: "",selected: false, isValided: false))
        
        return infoArray
    }
    
    func validateFields(dataStore: [SigninInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .number:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" || !dataStore[index].value.trimmingCharacters(in: .whitespaces).validateUsername(str: dataStore[index].value) {
                    validHandler([:],NSLocalizedString(LanguageText.number.rawValue, comment: ""), false)
                    return
                }
                dictParam["username"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            }
        }
        validHandler(dictParam, "", true)
    }
    
    
    struct SigninResponseModel : Mappable {
        var accessToken : String?
        var refreshToken : String?
        var userName : String?
        var userId : Int?
        var email : String?
        var roleName : String?
        var roleId :Int?
        var isactive : Bool?
        var message : String?
        var profile_img : String?

        init?(map: Map) {

        }
        
        init(){
            
        }

        mutating func mapping(map: Map) {
            accessToken <- map["accessToken"]
            refreshToken <- map["refreshToken"]
            userName <- map["userName"]
            userId <- map["userId"]
            email <- map["email"]
            roleName <- map["roleName"]
            roleId <- map["roleId"]
            isactive <- map["isactive"]
            message <- map["message"]
            profile_img <- map["profile_img"]

        }
    }
    
    func userSignIn(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (SigninResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<SigninResponseModel>().map(JSON: payload)
                    handler(dictResponce!,0)
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
