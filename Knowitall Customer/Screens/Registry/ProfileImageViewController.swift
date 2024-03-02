import UIKit

class ProfileImageViewController:  BaseViewController ,Storyboarded,UIScrollViewDelegate {
    var coordinator: MainCoordinator?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imgUrl : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let imageUrl = URL(string: imgUrl) {
            self.imageView.sd_setImage(with: imageUrl) { [weak self] (image, error, cacheType, url) in
                // Stop the activity indicator when the image loading is completed
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
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
