
import Foundation
import UIKit
import ObjectMapper


struct ProfileResponseModel : Mappable {
    var accessToken : String?
    var refreshToken : String?
    var customerId : String?
    var email : String?
    var code :String?
    var phoneNumber : String?
    var isactive : Bool?
    var message : String?
    var vehicleNumber : String?
    var dutyStarted : Bool?
    var requestInWeek : Int?
    var requestInDay : Int?
    var profileImage : String?
    var name : String?


    init?(map: Map) {

    }
    
    init() {

    }

    mutating func mapping(map: Map) {
        accessToken <- map["accessToken"]
        refreshToken <- map["refreshToken"]
        customerId <- map["customerId"]
        email <- map["email"]
        code <- map["code"]
        isactive <- map["isactive"]
        message <- map["message"]
        phoneNumber <- map["phoneNumber"]
        vehicleNumber <- map["vehicleNumber"]
        dutyStarted <- map["dutyStarted"]
        requestInWeek <- map["requestInWeek"]
        requestInDay <- map["requestInDay"]
        profileImage <- map["profileImage"]
        name <- map["name"]

        
    }
}


struct UserNotExist : Mappable {
    var message : String?
     var code : Int?

    init?(map: Map) {

    }
    
    init() {

    }

    mutating func mapping(map: Map) {
        message <- map["message"]
        code <- map["code"]
    }
}

enum FiledProfileType {
    case name
    case email

}


struct ProfileInfoModel{
    var type : FiledProfileType
    var placeholder : String
    var value : String
    var header : String


    
    
    init(type: FiledProfileType, placeholder: String = "", value: String = "",header: String) {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header

    }
}



class ProfileViewModel {
    var dictInfo = [String : String]()
    var infoArray = [ProfileInfoModel]()
    
    var mobileNumber : String = ""
    
    
    func prepareInfo(dictInfo : [String :String])-> [ProfileInfoModel]  {
        
        infoArray.append(ProfileInfoModel(type: .name, placeholder: NSLocalizedString(LanguageText.name.rawValue, comment: ""), value: "", header: "Name"))
        
        infoArray.append(ProfileInfoModel(type: .email, placeholder: NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), value: "", header: "Email"))
        
        
        return infoArray
    }
    
    func validateFields(dataStore: [ProfileInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""{
                    validHandler([:],NSLocalizedString(LanguageText.pleaseEnterName.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["name"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .email:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) != "" && !dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidEmail() {
                    validHandler([:], NSLocalizedString(LanguageText.validEmail.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func getUserData(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (ProfileResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<ProfileResponseModel>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    
                    if(payload["code"] as? Int == 101){
                        handler(ProfileResponseModel(),101)

                    }else{
                        handler(ProfileResponseModel(),-1)

                    }
                }
            }
        })
    }
}
