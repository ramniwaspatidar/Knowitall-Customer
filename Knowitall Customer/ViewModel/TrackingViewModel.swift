
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
    var requestId : String = ""

    var isMenu : Bool = false

    let defaultCellHeight = 72
    
    
    func prepareInfo()-> [TrackingModel]  {
        
        let requestTime = AppUtility.getTimeFromTimeEstime(dictRequest?.requestDate ?? 0)
        let accepted = dictRequest?.accepted ?? false
        let driverArrived = dictRequest?.driverArrived ?? false
        let confirmArrival = dictRequest?.confirmArrival ?? false
        let cancel = dictRequest?.cancelled ?? false
        let markNOShow = dictRequest?.markNoShow ?? false
        let completed = dictRequest?.completed ?? false
        let requestDate = AppUtility.getTimeFromTimeEstime(dictRequest?.confrimArrivalDate ?? 0.0)
        let cancelDate = AppUtility.getTimeFromTimeEstime(dictRequest?.cancelledDate ?? 0.0)
        let driverArrivedDate = AppUtility.getTimeFromTimeEstime(dictRequest?.driverArrivedDate ?? 0.0)
        let markNoShowDate = AppUtility.getTimeFromTimeEstime(dictRequest?.markNoShowDate ?? 0.0)





        
        if(cancel == true){
            infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
            if( driverArrived){
                infoArray.append(TrackingModel(eta: "Job Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
//                infoArray.append(TrackingModel(eta: "Driver Reaced at Location", value: "Help is on the way",  color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: driverArrivedDate, value: "Help Reached", color: "36D91B", status:"done"))
            }
            else if(accepted == true){
                infoArray.append(TrackingModel(eta: "Driver Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "Driver was on the way", value: "Help is on the way",  color: "#9CD4FC", status:"done"))
//                infoArray.append(TrackingModel(eta: "Cancelled", value: "Help Reached", color: "9CD4FC", status:"pending"))
            } 
//            else {
//                infoArray.append(TrackingModel(eta: "Cancelled", value: "Driver Response ", color:  "A2A2A2", status:"pending"))
//                infoArray.append(TrackingModel(eta: "Cancelled", value: "Help is on the way",  color: "A2A2A2", status:"pending"))
//                infoArray.append(TrackingModel(eta: "Cancelled", value: "Help Reached", color: "A2A2A2", status:"pending"))
//            }
            
           infoArray.append(TrackingModel(eta: cancelDate, value: "Booking Cancelled", color: "FF543E", status:"pending"))
        }
        else if(markNOShow == true){
            infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
            
            if( driverArrived){
                infoArray.append(TrackingModel(eta: "Job Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "Driver Reaced at Location", value: "Help is on the way",  color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: driverArrivedDate, value: "Help Reached", color: "36D91B", status:"done"))
            }
            else if(accepted == true){
                infoArray.append(TrackingModel(eta: "Driver Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "Driver was on the way", value: "Help is on the way",  color: "#9CD4FC", status:"done"))
            }
            
           infoArray.append(TrackingModel(eta: markNoShowDate, value: "Tow Not Found", color: "FF543E", status:"pending"))
        }
        else if( completed){
                infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
                infoArray.append(TrackingModel(eta: "Job Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
//                infoArray.append(TrackingModel(eta: "Driver Reaced at Location", value: "Help is on the way",  color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: requestDate, value: "Help Reached", color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: requestDate, value: "Arrival Confirmed", color: "36D91B", status:"done"))
               infoArray.append(TrackingModel(eta: requestDate, value: "Booking Completed", color: "36D91B", status:"done"))

        }
        else if( confirmArrival){
                infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
                infoArray.append(TrackingModel(eta: "Job Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
//                infoArray.append(TrackingModel(eta: "ETA calculating", value: "Help is on the way",  color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "\(requestDate)", value: "Help Reached", color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: requestDate, value: "Arrival Confirmed", color: "36D91B", status:"done"))
        }
        else if( driverArrived){
                infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
                infoArray.append(TrackingModel(eta: "Job Accepted", value: "Driver Response ", color:  "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "Driver Reaced at Location", value: "Help is on the way",  color: "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "Press confirm arrival to continue", value: "Help Reached", color: "36D91B", status:"done"))
        }
        else if(accepted == true){
                infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
                infoArray.append(TrackingModel(eta: "Driver Coming", value: "Driver Response ", color:  "36D91B", status:"done"))
                infoArray.append(TrackingModel(eta: "ETA Calculating", value: "Help is on the way",  color: "#9CD4FC", status:"pending"))
                infoArray.append(TrackingModel(eta: "Pending", value: "Help Reached", color: "9CD4FC", status:"pending"))
        }
        else{
            infoArray.append(TrackingModel(eta: requestTime, value: "Request Submitted" , color: "36D91B" , status: "done"))
            infoArray.append(TrackingModel(eta: "Waiting", value: "Driver Response ", color:  "#9CD4FC", status:"pending"))
            infoArray.append(TrackingModel(eta: "Pending", value: "Help is on the way",  color: "#9CD4FC", status:"pending"))
            infoArray.append(TrackingModel(eta: "Pending", value: "Help Reached", color: "9CD4FC", status:"pending"))
        }
        return infoArray
    }
    
    func getRequestData(_ apiEndPoint: String,_ isLoading : Bool = true, handler: @escaping (RequestListModal,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, isLoading, "", networkHandler: {(responce,statusCode) in
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
