

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
    
    @IBOutlet weak var webView: WKWebView!
    
    var webViewType : WebViewType?
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        super.viewDidLoad()
        setNavWithOutView(.menu)
        loadHTMPPage()
        
    }
    
    fileprivate func loadHTMPPage(){
        if webViewType == WebViewType.TC{
            lblHeading?.text = "Terms & Condition"
            
            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        else if webViewType == WebViewType.policy{
            lblHeading?.text = "Privacy Policy"
            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
        else if webViewType == WebViewType.FAQ
        {
            lblHeading?.text = "FAQ’s"
            
            if let htmlPath = Bundle.main.path(forResource: "faq", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }

    
}
