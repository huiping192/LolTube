
import Foundation

class ChannelDetailViewController: UIViewController {
 
    var channelId:String!
    
    @IBOutlet private weak var thumbnailImageView:UIImageView!
    @IBOutlet private weak var backgroundThumbnailImageView:UIImageView!
    @IBOutlet private weak var videoCountLabel:UILabel!
    @IBOutlet private weak var viewCountLabel:UILabel!
    @IBOutlet private weak var subscriberCountLabel:UILabel!

    @IBOutlet private weak var containView:UIView!
    
    private var viewModel:ChannelDetailViewModel!
    private let imageLoadingOperationQueue = NSOperationQueue()

    private var videoListViewController:VideoListViewController?
    private var playlistsViewController:PlaylistsViewController?
    private var channelInfoViewController:ChannelInfoViewController?
    private weak var currentViewController:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChannelDetailViewModel(channelId: channelId)
        configureVideoListViewController()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        cleanup()
    }
    
    private func configureNavigationBar(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        navigationController?.navigationBar.titleTextAttributes = navbarTitleTextAttributes
        
        navigationController?.navigationBar.shadowImage = createImageWithColor(UIColor.clearColor())
        navigationController?.navigationBar.setBackgroundImage(createImageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black;

    }
    
    private func resetNavigationBarSettings(){
        let navbarTitleTextAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.blackColor()]
        navigationController?.navigationBar.titleTextAttributes = navbarTitleTextAttributes
        
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIApplication.sharedApplication().keyWindow?.tintColor
        navigationController?.navigationBar.barStyle = .Default;

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resetNavigationBarSettings()
        cleanup()
    }
    
    private func cleanup(){
        videoListViewController = nil
        playlistsViewController = nil
        channelInfoViewController = nil
    }
    
    private func loadData(){
        viewModel.update(success: {
            [unowned self] in
            guard let channel = self.viewModel.channel else {
                return
            }
                
            self.navigationItem.title = channel.title
            self.viewCountLabel.text = channel.viewCountString
            self.videoCountLabel.text = channel.videoCountString
            self.subscriberCountLabel.text = channel.subscriberCountString
            
            let imageOperation = UIImageView.asynLoadingImageWithUrlString(channel.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
                [unowned self] image in
                self.thumbnailImageView.image = image
            }
            
            self.imageLoadingOperationQueue.addOperation(imageOperation)
            
            let bannerImageOperation = UIImageView.asynLoadingImageWithUrlString(channel.bannerImageUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
                [unowned self] image in
                self.backgroundThumbnailImageView.image = image
            }
            
            self.imageLoadingOperationQueue.addOperation(bannerImageOperation)
            
            }, failure: {
                [unowned self] error in
                self.showError(error)
            })
    }
    
    private func configureVideoListViewController(){
        if videoListViewController == nil {
            self.videoListViewController = instantiateVideoListViewController(channelId)
        }
        
        guard let videoListViewController = videoListViewController else {
            return
        }
        swapToChildViewController(videoListViewController)
    }
    
    private func configurePlaylistsViewController(){
        if playlistsViewController == nil{
            self.playlistsViewController = instantiatePlaylistsViewController(channelId)
        }
        guard let playlistsViewController = playlistsViewController else {
            return
        }
        swapToChildViewController(playlistsViewController)
    }
    
    private func configureInfoViewController(){
        if let description = viewModel.channel?.description where channelInfoViewController == nil{
            self.channelInfoViewController = instantiateChannelInfoViewController(description)
        }
        
        guard let channelInfoViewController = channelInfoViewController else {
            return
        }
        swapToChildViewController(channelInfoViewController)
    }
    
    private func swapToChildViewController(childViewController:UIViewController){
        if let currentViewController = currentViewController {
            removeViewController(currentViewController)
        }
        
        addConstraintsForViewController(childViewController)
        addChildViewController(childViewController)
        childViewController.didMoveToParentViewController(self)
        currentViewController = childViewController
    }
    
    private func removeViewController(viewController:UIViewController?){
        if let viewController = viewController {
            viewController.willMoveToParentViewController(nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
    
    private func addConstraintsForViewController(viewController:UIViewController){
        let childView = viewController.view
        childView.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(childView)
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
    }
    
    @IBAction func segmentValueChanged(segmentedControl:UISegmentedControl){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            configureVideoListViewController()
        case 1:
            configurePlaylistsViewController()
        case 2:
            configureInfoViewController()
        default:
            break
        }
        
    }

}