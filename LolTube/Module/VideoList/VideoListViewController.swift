import Foundation


class VideoListViewController: SimpleListCollectionViewController {

    var channelId:String!

    let imageLoadingOperationQueue = NSOperationQueue()

    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return VideoListViewModel(channelId:channelId)
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("relatedVideoCell", forIndexPath: indexPath) as! VideoCellectionViewCell
        let video = (viewModel as! VideoListViewModel).videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.duration
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = (viewModel as! VideoListViewModel).videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}
