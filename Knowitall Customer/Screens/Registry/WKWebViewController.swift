

import UIKit
import WebKit

enum WebViewType :Int{
    case TC
    case policy
    case FAQ
}
class WKWebViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    @IBOutlet weak var lblHeading: UILabel!
    
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    
    var webViewType : WebViewType?
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        super.viewDidLoad()
        setNavWithOutView(.menu)
        if (isiPhoneSE()) {
            self.labelTopConstraint.constant = 90
        // Safe area is available, adjust your layout accordingly
            
        }
        loadHTMPPage()
        
    }
    
    func isiPhoneSE() -> Bool {
            let deviceModel = UIDevice.current.model
            return deviceModel == "iPhone" && UIScreen.main.bounds.height <= 667
        }

    
    fileprivate func loadHTMPPage(){
        if webViewType == WebViewType.TC{
            lblHeading?.text = "Terms & Condition"
            webView.load(URLRequest(url: URL(string: "https://mrknowitalltowingpage.com/terms-of-use-customers")!))

            
//            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "pdf") {
//                let url = URL(fileURLWithPath: htmlPath)
//                let request = URLRequest(url: url)
//                webView.load(request)
//            }
        }
        else if webViewType == WebViewType.policy{
            lblHeading?.text = "Privacy Policy"
            webView.load(URLRequest(url: URL(string: "https://mrknowitalltowingpage.com/terms-of-use-customers")!))

//            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "pdf") {
//                let url = URL(fileURLWithPath: htmlPath)
//                let request = URLRequest(url: url)
//                webView.load(request)
//            }
        }
        
        else if webViewType == WebViewType.FAQ
        {
            lblHeading?.text = "FAQ’s"
            webView.load(URLRequest(url: URL(string: "https://mrknowitalltowingpage.com/faq")!))
//            if let htmlPath = Bundle.main.path(forResource: "faq", ofType: "html") {
//                let url = URL(fileURLWithPath: htmlPath)
//                let request = URLRequest(url: url)
//                webView.load(request)
//            }
        }
    }

    
}
