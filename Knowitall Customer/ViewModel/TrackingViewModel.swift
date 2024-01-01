
import Foundation
import UIKit
import ObjectMapper

struct TrackingModel{
    var eta : String
    var value : String
    var color : String
    var status : String
    
    init(eta: String, value: String, color : String,status : String) {
        self.eta = eta
        self.value = value
        self.color = color
        self.status = status
        
    }
}



class TrackingViewModel {
    
    var infoArray = [TrackingModel]()
    var dictRequest : RequestListModal?
    var isMenu : Bool = false

    let defaultCellHeight = 95
    
    
    func prepareInfo()-> [TrackingModel]  {
        
        let requestTime = AppUtility.getTimeFromTimeEstime(dictRequest?.requestDate ?? 0)
        let accepted = dictRequest?.accepted ?? false
        let driverArrived = dictRequest?.driverArrived ?? false
        let confirmArrival = dictRequest?.confirmArrival ?? false
        
        
        infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted", color: "#F4CC9E", status: "done"))
        infoArray.append(TrackingModel(eta: accepted ? "Driver Coming" : "Waiting for Acceptance", value: "Driver Response ", color: "#F4CC9E", status: accepted ? "done" : "pending"))
        infoArray.append(TrackingModel(eta: "", value: "Help is on the way", color: "#09C655", status: accepted ? "done":"pending"))
        infoArray.append(TrackingModel(eta: confirmArrival ? "Completed": "Pending", value: "Help Reached", color: "#DDDBD4", status: confirmArrival ? "done" : "pending"))

        return infoArray
    }
    
    func getRequestData(_ apiEndPoint: String, handler: @escaping (RequestListModal,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
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
    
    func cancelRequest(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (RequestListModal,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, false, "", params: param, networkHandler: {(responce,statusCode) in
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
