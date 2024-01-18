

import UIKit
import WebKit

enum WebViewType :Int{
    case TC
    case policy
    case FAQ
}
class WKWebViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var webView: WKWebView!
    
    var webViewType : WebViewType?
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        super.viewDidLoad()
        setNavWithOutView(.back)
        loadHTMPPage()
        
    }
    
    fileprivate func loadHTMPPage(){
        if webViewType == WebViewType.TC{
            headerLabel?.text = "Terms & Condition"
            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
//            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
        else if webViewType == WebViewType.policy{
            headerLabel?.text = "Privacy Policy"
            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
        
        else if webViewType == WebViewType.FAQ
        {
            headerLabel?.text = "FAQ’s"
            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
    }
    
}
