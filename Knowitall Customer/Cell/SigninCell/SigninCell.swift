

import UIKit

class SigninCell: ReusableTableViewCell {
    
    @IBOutlet weak var textFiled : CustomTextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblimage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func commiInit<T>(_ dictionary :T){
        
        if let dict = dictionary as? RequestTypeModel{
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
            lblimage.text = dict.header
            textFiled.textColor = .white
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }
    
    func commiAddressInit<T>(_ dictionary :T){
        
        if let dict = dictionary as? AddressTypeModel{
            textFiled.text = dict.value
            textFiled.textColor = .white
            textFiled.placeholder = dict.placeholder
            lblimage.text = dict.header
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }
    
    fileprivate func setValue(){
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
