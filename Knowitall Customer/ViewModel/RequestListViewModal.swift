
import Foundation
import UIKit
import ObjectMapper


struct RequestListModal : Mappable {
    
    
    var  address : String?
    var city : String?
    var country : String?
    var customerId : String?
    var desc : String?
    var latitude : Double?
    var longitude : Double?
    var name : String?
    var phoneNumber : String?
    var typeOfService : String?
    var state : String?
    var requestDate : Double?
    var requestId : String?
    var accepted : Bool?
    var arrivalCode : Int?
    var declineDrivers :[DeclineDrivers]?
    var driverId : String?
    var driverArrived : Bool?
    var  confirmArrival : Bool?
    var confrimArrivalDate : Double?
    var requestAcceptDate : Double?
    var reqDispId : String?
    var driverLocation : DriverLocation?
    var cancelled : Bool?
    var markNoShow : Bool?
    var driverPhoneNumber : String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        address <- map["address"]
        city <- map["city"]
        country <- map["country"]
        customerId <- map["customerId"]
        desc <- map["desc"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        name <- map["name"]
        phoneNumber <- map["phoneNumber"]
        typeOfService <- map["typeOfService"]
        state <- map["state"]
        requestDate <- map["requestDate"]
        requestId <- map["requestId"]
        accepted <- map["accepted"]
        arrivalCode <- map["arrivalCode"]
        declineDrivers <- map["declineDrivers"]
        driverId <- map["driverId"]
        driverArrived <- map["driverArrived"]
        confirmArrival <- map["confirmArrival"]
        confrimArrivalDate <- map["confrimArrivalDate"]
        requestAcceptDate <- map["requestAcceptDate"]
        reqDispId <- map["reqDispId"]
        driverLocation <- map["driverLocation"]
        cancelled <- map["cancelled"]
        markNoShow <- map["markNoShow"]
        driverPhoneNumber <- map["driverPhoneNumber"]

    
    }
}

struct DeclineDrivers : Mappable {
    
    var  driverId : String?
    var date : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        driverId <- map["driverId"]
        date <- map["date"]
    }
}

struct DriverLocation : Mappable {
    
    var  latitude : Double?
    var longitude : Double?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}



class RequestListViewModal {
    
    var requestModel : RequestModel?
    var listArray = [RequestListModal]()
    let defaultCellHeight = 120
    
    func sendRequest(_ apiEndPoint: String, handler: @escaping ([RequestListModal],Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            if(statusCode == 200){
                let dictResponce =  Mapper<RequestListModal>().mapArray(JSONArray: responce["payload"] as! [[String : Any]])
                handler(dictResponce,statusCode)
            }
            
            else{
                DispatchQueue.main.async {
                    Alert(title: "", message: "", vc: RootViewController.controller!)
                }
                
            }
        })
    }
    
}
