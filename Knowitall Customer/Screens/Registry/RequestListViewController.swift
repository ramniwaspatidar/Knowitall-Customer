
import UIKit
import FirebaseAuth
import Firebase

class RequestListViewController: BaseViewController,Storyboarded{
    
    var coordinator: MainCoordinator?
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var norequestLabel: UILabel!
    
    
    var viewModel : RequestListViewModal = {
        let model = RequestListViewModal()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tblView.addSubview(refreshControl)
        coordinator = MainCoordinator(navigationController: self.navigationController!)
        self.setNavWithOutView(.menu)
//        headerLabel?.text = "Requests"
        RequestCell.registerWithTable(tblView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllRequestList()
    }
    
    
    @objc func refresh(_ sender: Any) {
        refreshControl.endRefreshing()
        self.getAllRequestList(false)
    }
    
    func getAllRequestList(_ loading : Bool = true){
        viewModel.sendRequest(APIsEndPoints.kRequestList.rawValue,loading) { response, code in
            
            self.viewModel.listArray  = response
            
            if(response.count > 0){
                self.tblView.reloadData()

            }else{
                self.norequestLabel.isHidden = false
            }
        }
    }
    
}
// UITableViewDataSource
extension RequestListViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: RequestCell.reuseIdentifier, for: indexPath) as! RequestCell
        cell.selectionStyle = .none
        cell.commonInit(viewModel.listArray[indexPath.row])
        
        return cell
    }
}

extension RequestListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        coordinator?.goToTrackingView(self.viewModel.listArray[indexPath.row].requestId ?? "",true)
    }
}
