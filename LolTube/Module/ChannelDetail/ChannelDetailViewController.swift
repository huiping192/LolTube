
import Foundation

class ChannelDetailViewController: UIViewController {
 
    var channelId:String!
    
    @IBOutlet private weak var thumbnailImageView:UIImageView!
    @IBOutlet private weak var backgroundThumbnailImageView:UIImageView!
    @IBOutlet private weak var videoCountLabel:UILabel!
    @IBOutlet private weak var viewCountLabel:UILabel!
    @IBOutlet private weak var subscriberCountLabel:UILabel!

    @IBOutlet private weak var subscribeButton:UIButton!

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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configureNavigationBar(.Clear)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.configureNavigationBar(.Default)
    }
    
    
    @IBAction func subscribeButtonTapped(button:UIButton){
        let successBlock:(() -> Void) = {
            [unowned self] in
            guard let isSubscribed = self.viewModel.isSubscribed else {
                return
            }
            let buttonTitle = isSubscribed ? NSLocalizedString("ChannelSubscribed", comment: "") : NSLocalizedString("ChannelUnsubscribe", comment: "")
            self.subscribeButton.setTitle(buttonTitle, forState: .Normal)
        }
        
        let failureBlock:((NSError) -> Void) = {
            [unowned self] error in
            self.showError(error)
        }
        
        viewModel.subscribeChannel(success: successBlock, failure: failureBlock)
    }
    
    private func cleanup(){
        videoListViewController = nil
        playlistsViewController = nil
        channelInfoViewController = nil
    }
    
    private func loadData(){
        
        let successBlock:(() -> Void) = {
            [unowned self] in
            guard let channel = self.viewModel.channel , let isSubscribed = self.viewModel.isSubscribed else {
                return
            }
            
            self.navigationItem.title = channel.title
            self.viewCountLabel.text = channel.viewCountString
            self.videoCountLabel.text = channel.videoCountString
            self.subscriberCountLabel.text = channel.subscriberCountString
            
            let buttonTitle = isSubscribed ? NSLocalizedString("ChannelSubscribed", comment: "") : NSLocalizedString("ChannelUnsubscribe", comment: "")
            self.subscribeButton.setTitle(buttonTitle, forState: .Normal)
            
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
            
        }
        
        let failureBlock:((NSError) -> Void) = {
            [unowned self] error in
            self.showError(error)
        }
        viewModel.update(success: successBlock, failure: failureBlock)
    }
    
    private func configureVideoListViewController(){
        self.videoListViewController = configureChildViewController(self.videoListViewController){
            [unowned self] in
            return self.instantiateVideoListViewController(self.channelId)
        }
    }
    
    private func configurePlaylistsViewController(){
        self.playlistsViewController = configureChildViewController(self.playlistsViewController){
            [unowned self] in
            return self.instantiatePlaylistsViewController(self.channelId)
        }
    }
    
    private func configureInfoViewController(){
        self.channelInfoViewController = configureChildViewController(self.channelInfoViewController){
            [unowned self] in
            return self.instantiateChannelInfoViewController(self.viewModel.channel?.description ?? "")
        }
    }
    
    private func configureChildViewController<T:UIViewController>(childViewController:T?,initBlock:(() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
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
        guard let viewController = viewController else {
            return
        }
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    private func addConstraintsForViewController(viewController:UIViewController){
        let childView = viewController.view
        childView.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(childView)
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
    }
    
    enum ChannelDetailType:Int {
        case VideoList = 0
        case Playlists
        case ChannelInfo
    }
    
    @IBAction func segmentValueChanged(segmentedControl:UISegmentedControl) {
        guard let detailType = ChannelDetailType(rawValue: segmentedControl.selectedSegmentIndex) else {
            return
        }
        
        switch  detailType{
        case .VideoList:
            configureVideoListViewController()
        case .Playlists:
            configurePlaylistsViewController()
        case .ChannelInfo:
            configureInfoViewController()
        }
    }
}