import UIKit

class ProfileImageViewController:  BaseViewController ,Storyboarded,UIScrollViewDelegate {
    var coordinator: MainCoordinator?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imgUrl : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: imgUrl) {
            
            DispatchQueue.global().async { [weak self] in
                       if let data = try? Data(contentsOf: url) {
                           if let image = UIImage(data: data) {
                               DispatchQueue.main.async {
                                   self?.imageView.image = image
                               }
                           }
                       }
                   }
               }
        
        // Set up pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        imageView.isUserInteractionEnabled = true
        
        // Set up scrollView
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        
        self.setNavWithOutView(.back)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else { return }
        
        if sender.state == .began || sender.state == .changed {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1.0
        }
    }
}
