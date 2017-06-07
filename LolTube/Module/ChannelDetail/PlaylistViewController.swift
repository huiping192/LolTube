import Foundation

class PlaylistViewController: VideoCollectionViewController {
    
    var playlistId:String!
    var playlistTitle:String!
    
    var viewModel:PlaylistViewModel!
    
    fileprivate let imageLoadingOperationQueue = OperationQueue()

    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelPlaylistEmptyData", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = playlistTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Playlist Detail", viewType: PlaylistViewController.self, viewId: playlistTitle)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = PlaylistViewModel(playlistId: playlistId)
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell( indexPath, type: PlaylistCollectionViewCell.self)
        let video = viewModel.videoList[indexPath.row]
        
        cell.videoNumberLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: PlaylistCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(_ indexPath: IndexPath){
        let cellVo = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiateVideoDetailViewController(cellVo.videoId), animated: true)
    }
}
