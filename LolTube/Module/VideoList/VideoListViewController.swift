import Foundation

class VideoListViewController: VideoCollectionViewController {

    var channelId:String!

    var viewModel:VideoListViewModel!
    private let imageLoadingOperationQueue = NSOperationQueue()

    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelVideoEmptyData", comment: "")
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = VideoListViewModel(channelId:channelId)
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
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
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}
