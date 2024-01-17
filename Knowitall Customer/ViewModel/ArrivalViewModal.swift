
import Foundation
import UIKit
import ObjectMapper

struct ArrivalModal{
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



class ArrivalViewModal {
            
    func confirmArrival(_ apiEndPoint: String,_ param : [String : Any], hud : Bool = false, handler: @escaping (RequestListModal?,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, hud, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<RequestListModal>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    DispatchQueue.main.async {
                        handler(nil,-1)

                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }

    
    
}
