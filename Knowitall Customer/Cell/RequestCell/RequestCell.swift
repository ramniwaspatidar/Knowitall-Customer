//
//  RequestCell.swift
//  Knowitall Customer
//
//  Created by Ramniwas Patidar on 28/12/23.
//

import UIKit

class RequestCell: ReusableTableViewCell {
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func commonInit(_ dict : RequestListModal){
        requestLabel.text = "Request ID : \(dict.reqDispId ?? "")"
        dateLabel.text = AppUtility.getDateFromTimeEstime(dict.requestDate ?? 0.0)
        
        if(dict.completed == true){
            statusLabel.text = "Booking Completed"
            statusLabel.textColor = hexStringToUIColor("36D91B")
        }
        else if(dict.cancelled == true){
            statusLabel.text = "Cancelled"
            statusLabel.textColor = hexStringToUIColor("FF004F")
        }
        else  if(dict.markNoShow == true){
            statusLabel.text = "Tow Not Found"
            statusLabel.textColor = hexStringToUIColor("FF004F")
        }
       else if(dict.confirmArrival == true){
            statusLabel.text = "Arrival Confirmed"
           statusLabel.textColor = hexStringToUIColor("36D91B")
        }
       
       else if(dict.driverArrived == true){
            statusLabel.text = "Help Reached"
            statusLabel.textColor = hexStringToUIColor("F7D63D")
        }
        
        else if(dict.accepted == true){
             statusLabel.text = "Help Comming"
             statusLabel.textColor = hexStringToUIColor("F7D63D")
         }
        else {
             statusLabel.text = "Request Submitted"
             statusLabel.textColor = hexStringToUIColor("F7D63D")
         }        
    }
    
    
   
}
