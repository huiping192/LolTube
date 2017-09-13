
import Foundation

class ChannelDetailViewController: UIViewController {
 
    var channelId:String!
    var channelTitle:String!

    @IBOutlet fileprivate weak var thumbnailImageView:UIImageView!{
        didSet{
            thumbnailImageView.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        }
    }
    @IBOutlet fileprivate weak var backgroundThumbnailImageView:UIImageView!{
        didSet{
            backgroundThumbnailImageView.image = UIImage(named: "DefaultThumbnail")
        }
    }
    @IBOutlet fileprivate weak var videoCountLabel:UILabel!
    @IBOutlet fileprivate weak var viewCountLabel:UILabel!
    @IBOutlet fileprivate weak var subscriberCountLabel:UILabel!

    @IBOutlet fileprivate weak var subscribeButton:UIButton!

    @IBOutlet fileprivate weak var containView:UIView!
    
    fileprivate var viewModel:ChannelDetailViewModel!
    fileprivate let imageLoadingOperationQueue = OperationQueue()

    fileprivate var videoListViewController:VideoListViewController?
    fileprivate var playlistsViewController:PlaylistsViewController?
    fileprivate var channelInfoViewController:ChannelInfoViewController?
    fileprivate weak var currentViewController:UIViewController?
    
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Detail", viewType: ChannelDetailViewController.self, viewId: channelTitle)
        
        navigationController?.navigationBar.configureNavigationBar(.clear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.configureNavigationBar(.default)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    @IBAction func subscribeButtonTapped(_ button:UIButton){
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
    
    fileprivate func cleanup(){
        videoListViewController = nil
        playlistsViewController = nil
        channelInfoViewController = nil
    }
    
    fileprivate func updateSubscribeButton(_ isSubscribed:Bool){
        let buttonTitle = isSubscribed ? NSLocalizedString("ChannelSubscribed", comment: "") : NSLocalizedString("ChannelUnsubscribe", comment: "")
        let buttonColor = isSubscribed ? UIColor(white: 1.0, alpha: 0.6) : view.tintColor
        subscribeButton.setTitle(buttonTitle, for: UIControlState())
        subscribeButton.setTitleColor(buttonColor, for: UIControlState())
    }
    
    fileprivate func loadData(){
        
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
                
                if UIColor.white.equal(imageAverageColor!, tolerance: 0.3) {
                    weakSelf.viewCountLabel.textColor = UIColor.darkGray
                    weakSelf.videoCountLabel.textColor = UIColor.darkGray
                    weakSelf.subscriberCountLabel.textColor = UIColor.darkGray
                    weakSelf.subscribeButton.setTitleColor(UIColor.darkGray, for: UIControlState())

                    weakSelf.navigationController?.navigationBar.configureNavigationBar(.clearBlack)
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
    
    fileprivate func configureVideoListViewController(){
        self.videoListViewController = configureChildViewController(self.videoListViewController){
            return ViewControllerFactory.instantiateVideoListViewController(self.channelId,channelTitle:channelTitle)
        }
    }
    
    fileprivate func configurePlaylistsViewController(){
        self.playlistsViewController = configureChildViewController(self.playlistsViewController){
            return ViewControllerFactory.instantiatePlaylistsViewController(self.channelId,channelTitle:channelTitle)
        }
    }
    
    fileprivate func configureInfoViewController(){
        self.channelInfoViewController = configureChildViewController(self.channelInfoViewController){
            return ViewControllerFactory.instantiateChannelInfoViewController(self.viewModel.channel?.description ?? "",channelId:self.channelId,channelTitle:channelTitle)
        }
    }
    
    fileprivate func configureChildViewController<T:UIViewController>(_ childViewController:T?,initBlock: (() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
    }
    
    fileprivate func swapToChildViewController(_ childViewController:UIViewController){
        if let currentViewController = currentViewController {
            removeViewController(currentViewController)
        }
        
        addConstraintsForViewController(childViewController)
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
        currentViewController = childViewController
    }
    
    fileprivate func removeViewController(_ viewController:UIViewController?){
        guard let viewController = viewController else {
            return
        }
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    fileprivate func addConstraintsForViewController(_ viewController:UIViewController){
        let childView = viewController.view
        childView?.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(childView!)
        containView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
        containView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
    }
    
    enum ChannelDetailType:Int {
        case videoList = 0
        case playlists
        case channelInfo
    }
    
    @IBAction func segmentValueChanged(_ segmentedControl:UISegmentedControl) {
        guard let detailType = ChannelDetailType(rawValue: segmentedControl.selectedSegmentIndex) else {
            return
        }
        
        switch  detailType{
        case .videoList:
            configureVideoListViewController()
        case .playlists:
            configurePlaylistsViewController()
        case .channelInfo:
            configureInfoViewController()
        }
    }
}

extension ChannelDetailViewController {
    override func fetchNewData(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let fetchableChildViewController = currentViewController as? BackgroundFetchable else {
            completionHandler(.failed)
            return
        }
        
        fetchableChildViewController.fetchNewData(completionHandler)
    }
}
