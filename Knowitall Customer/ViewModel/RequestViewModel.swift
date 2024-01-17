
import Foundation
import UIKit
import ObjectMapper



enum RequestFieldType {
    case service
    case description
    case name
    case mobile
    
}

struct RequestTypeModel{
    var type : RequestFieldType
    var placeholder : String
    var value : String
    var header : String
    
    init(type: RequestFieldType, placeholder: String = "", value: String = "", header : String = "") {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header
    }
}


class RequestViewModel {
    
    var requestModel : RequestModel?
    var dictInfo = [String : String]()
    var infoArray = [RequestTypeModel]()
    var addressInfo : [AddressTypeModel]?
    let defaultCellHeight = 95
    
    var requestData : RequestListModal?
    
    
    func prepareInfo(dictInfo : [String :String])-> [RequestTypeModel]  {
        
        let phoneNumber = requestData?.phoneNumber?.components(separatedBy: "+")
        var number = CurrentUserInfo.phone ?? ""
        let name = CurrentUserInfo.userName ??  ""

        
        
        if(phoneNumber?.count ?? 0 > 1){
            number = phoneNumber?[1] ?? CurrentUserInfo.phone
        }else if (requestData != nil){
            number = requestData?.phoneNumber ?? CurrentUserInfo.phone
        }
        
        
        infoArray.append(RequestTypeModel(type: .service, placeholder: NSLocalizedString("Type of service request", comment: ""), value: requestModel?.requestType ?? "Accident", header: "Type of service requested"))
        
        infoArray.append(RequestTypeModel(type: .description, placeholder: NSLocalizedString("Type ...", comment: ""), value: requestModel?.requestType ?? "", header: "Please briefly explain the situation"))
        
        infoArray.append(RequestTypeModel(type: .name, placeholder: NSLocalizedString("Enter name", comment: ""), value: requestModel?.name ?? name, header: "Your Name"))
        
        infoArray.append(RequestTypeModel(type: .mobile, placeholder: NSLocalizedString("Enter mobile number", comment: ""), value:number, header: "Your Phone"))
        
        return infoArray
    }
    
   
    func validateFields(dataStore: [RequestTypeModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .service:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Type of service requested", false)
                    return
                }
                
                dictParam["service"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .description:
//                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
//                    validHandler([:],"Please briefly explain the situation", false)
//                    return
//                }
                
                dictParam["description"] = "" as AnyObject
                
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Enter  name", false)
                    return
                }
                dictParam["name"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .mobile:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter mobile number", false)
                    return
                }
                
                dictParam["number"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
         
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func sendRequest(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (RequestListModal,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<RequestListModal>().map(JSON: payload)
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
