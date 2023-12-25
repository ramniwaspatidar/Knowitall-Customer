
import UIKit
import SideMenu

class BaseViewController: UIViewController {
    
    var backButton : CustomButton!
    var buttonHeight : CGFloat = 40
    var button_y_Axis: CGFloat = 44
    var imgView : UIImageView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
//
        self.setNavWithOutView()


        
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imgView?.image = UIImage(named: "bg")
//        self.view.addSubview(imgView!)
    }
    
  
    func setNavWithOutView(){
        
        var topBarHeight = 34
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height >= 812.0 {
            topBarHeight = topBarHeight + 44
        }else{
            topBarHeight = topBarHeight + 64
        }
        
        // menu Button
        backButton = CustomButton(frame: CGRect(x: 16, y: CGFloat((topBarHeight)/2) , width: 70, height: 50))
        backButton!.addTarget(self, action:#selector(menuButtonAction), for: .touchUpInside)
        backButton.setImage(UIImage(named: "menu"), for: .normal)
        self.view.addSubview(backButton!)
        
    }
    
    @objc func menuButtonAction() {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)

        

    }

}
