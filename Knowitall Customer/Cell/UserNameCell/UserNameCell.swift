

import UIKit

class UserNameCell: ReusableTableViewCell {
    
    @IBOutlet weak var textFiled : CustomTextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func commiInit<T>(_ dictionary :T){
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.cornerRadius = 8
        
        if let dict = dictionary as? ProfileInfoModel{
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
            headerLabel.text = dict.header
            
        }
    }
    
    fileprivate func setValue(){
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
