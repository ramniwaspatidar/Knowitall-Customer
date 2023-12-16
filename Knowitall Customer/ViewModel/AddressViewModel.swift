
import Foundation
import UIKit
import ObjectMapper



enum AddressFieldType {
    case address1
    case address2
    case city
    case state
    case landMark
}

struct AddressTypeModel{
    var type : AddressFieldType
    var placeholder : String
    var value : String
    var header : String
    
    init(type: AddressFieldType, placeholder: String = "", value: String = "", header : String = "") {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header
    }
}



class AddressViewModel {
    
    var addressModel : AddressModel?
    var dictInfo = [String : String]()
    var infoArray = [AddressTypeModel]()
    let defaultCellHeight = 95
    
    
    func prepareInfo(dictInfo : [String :String])-> [AddressTypeModel]  {
        
        infoArray.append(AddressTypeModel(type: .address1, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.address1 ?? "", header: "Address Line 1"))
        
        infoArray.append(AddressTypeModel(type: .address2, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.address2 ?? "", header: "Address Line 2"))
        
        infoArray.append(AddressTypeModel(type: .city, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.address1 ?? "", header: "City"))
        
        infoArray.append(AddressTypeModel(type: .state, placeholder: NSLocalizedString("Select", comment: ""), value: addressModel?.address1 ?? "", header: "State"))
        
        infoArray.append(AddressTypeModel(type: .landMark, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.address1 ?? "", header: "Land Mark"))
        

        return infoArray
    }
    
   
    func validateFields(dataStore: [AddressTypeModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .address1:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Enter  address line1", false)
                    return
                }
                dictParam["address1"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .address2:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter address line 2", false)
                    return
                }
                dictParam["address2"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .city:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter city name", false)
                    return
                }
                
                dictParam["city"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .state:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Select state type", false)
                    return
                }
                
                dictParam["state"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .landMark:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter landmark", false)
                    return
                }
                dictParam["landmark"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject

            }
        }
        
        validHandler(dictParam, "", true)
    }
    
}
