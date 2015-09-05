
import Foundation

class ChannelDetailViewController: UIViewController {
 
    var channelId:String!
    var channelTitle:String!

    @IBOutlet private weak var thumbnailImageView:UIImageView!{
        didSet{
            thumbnailImageView.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        }
    }
    @IBOutlet private weak var backgroundThumbnailImageView:UIImageView!{
        didSet{
            backgroundThumbnailImageView.image = UIImage(named: "DefaultThumbnail")
        }
    }
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
        navigationItem.title = channelTitle
        configureVideoListViewController()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        cleanup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Detail", viewType: ChannelDetailViewController.self, viewId: channelTitle)
        
        navigationController?.navigationBar.configureNavigationBar(.Clear)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.configureNavigationBar(.Default)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    @IBAction func subscribeButtonTapped(button:UIButton){
        if viewModel.isSubscribed ?? false {
            EventTracker.trackDeleteChannel(channelTitle: channelTitle, channelId: channelId)
        }else {
            EventTracker.trackAddChannel(channelTitle: channelTitle, channelId: channelId)
        }
        
        let successBlock:(() -> Void) = {
            [weak self] in
            guard let isSubscribed = self?.viewModel.isSubscribed else {
                return
            }
            
            self?.updateSubscribeButton(isSubscribed)
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self] error in
            self?.showError(error)
        }
        
        viewModel.subscribeChannel(success: successBlock, failure: failureBlock)
    }
    
    private func cleanup(){
        videoListViewController = nil
        playlistsViewController = nil
        channelInfoViewController = nil
    }
    
    private func updateSubscribeButton(isSubscribed:Bool){
        let buttonTitle = isSubscribed ? NSLocalizedString("ChannelSubscribed", comment: "") : NSLocalizedString("ChannelUnsubscribe", comment: "")
        let buttonColor = isSubscribed ? UIColor(white: 1.0, alpha: 0.6) : view.tintColor
        subscribeButton.setTitle(buttonTitle, forState: .Normal)
        subscribeButton.setTitleColor(buttonColor, forState: .Normal)
    }
    
    private func loadData(){
        
        let successBlock:(() -> Void) = {
            [weak self] in
            guard let channel = self?.viewModel.channel , let isSubscribed = self?.viewModel.isSubscribed else {
                return
            }
            
            self?.navigationItem.title = channel.title
            self?.viewCountLabel.text = channel.viewCountString
            self?.videoCountLabel.text = channel.videoCountString
            self?.subscriberCountLabel.text = channel.subscriberCountString
            
            self?.updateSubscribeButton(isSubscribed)
            
            if let thumbnailUrl = channel.thumbnailUrl {
                let imageOperation = ImageLoadOperation(url: thumbnailUrl){
                    [weak self] image in
                    self?.thumbnailImageView.image = image
                }
                self?.imageLoadingOperationQueue.addOperation(imageOperation)
            }
            
            let bannerImageOperation = ImageLoadOperation(url: channel.bannerImageUrl){
                [weak self] image in
                
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.backgroundThumbnailImageView.image = image
                let imageAverageColor = image.averageColor()
                
                if UIColor.whiteColor().equal(imageAverageColor, tolerance: 0.3) {
                    weakSelf.viewCountLabel.textColor = UIColor.darkGrayColor()
                    weakSelf.videoCountLabel.textColor = UIColor.darkGrayColor()
                    weakSelf.subscriberCountLabel.textColor = UIColor.darkGrayColor()
                    weakSelf.subscribeButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)

                    weakSelf.navigationController?.navigationBar.configureNavigationBar(.ClearBlack)
                }
            }
            self?.imageLoadingOperationQueue.addOperation(bannerImageOperation)
        }
        
        let failureBlock:((NSError) -> Void) = {
            [weak self] error in
            self?.showError(error)
        }
        viewModel.update(success: successBlock, failure: failureBlock)
    }
    
    private func configureVideoListViewController(){
        self.videoListViewController = configureChildViewController(self.videoListViewController){
            return self.instantiateVideoListViewController(self.channelId,channelTitle:channelTitle)
        }
    }
    
    private func configurePlaylistsViewController(){
        self.playlistsViewController = configureChildViewController(self.playlistsViewController){
            return self.instantiatePlaylistsViewController(self.channelId,channelTitle:channelTitle)
        }
    }
    
    private func configureInfoViewController(){
        self.channelInfoViewController = configureChildViewController(self.channelInfoViewController){
            return self.instantiateChannelInfoViewController(self.viewModel.channel?.description ?? "",channelId:self.channelId,channelTitle:channelTitle)
        }
    }
    
    private func configureChildViewController<T:UIViewController>(childViewController:T?,@noescape initBlock:(() -> T)) -> T{
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