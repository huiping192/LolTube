import Foundation

class VideoListViewController: VideoCollectionViewController {

    var channelId:String!
    var channelTitle:String!

    var viewModel:VideoListViewModel!
    fileprivate let imageLoadingOperationQueue = OperationQueue()

    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelVideoEmptyData", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Video", viewType: VideoListViewController.self, viewId: channelTitle)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = VideoListViewModel(channelId:channelId)
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: VideoCellectionViewCell.self)
        let video = viewModel.videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak collectionView] image in
                let cell = collectionView?.cell(indexPath, type: VideoCellectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(_ indexPath: IndexPath){
        let video = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}
