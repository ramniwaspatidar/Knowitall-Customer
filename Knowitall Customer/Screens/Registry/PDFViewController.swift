
import UIKit
import PDFKit

class PDFViewController: BaseViewController, Storyboarded {
    
    var coordinator: MainCoordinator?
    var pdfView = PDFView()
    
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavWithOutView(.back, self.view)
        
        
        pdfView.frame = CGRect(x:0, y: 0, width: bgView.frame.size.width, height: bgView.frame.size.height)
                pdfView.autoScales = true
        
        pdfView.layer.cornerRadius = 8
             bgView.addSubview(pdfView)

                // Load PDF document
                if let pdfURL = Bundle.main.url(forResource: "PTP", withExtension: "pdf"),
                   let pdfDocument = PDFDocument(url: pdfURL) {
                    pdfView.document = pdfDocument

                    // Navigate to the second page
                    if let secondPage = pdfDocument.page(at: 0) { // Index is zero-based
                        let destination = PDFDestination(page: secondPage, at: CGPoint.zero)
                        pdfView.go(to: destination)
                    }
                }

    }
    
}
