
import Foundation

class HistoryViewController:SimpleListCollectionViewController {
    
    let imageLoadingOperationQueue = NSOperationQueue()

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.update(success: {
            [unowned self] in
            self.collectionView.reloadData()
            },failure:{
                error in
                self.showError(error)
            }
        )
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return HistoryViewModel()
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("historyVideoCell", forIndexPath: indexPath) as! HistoryCollectionViewCell
        let video = (viewModel as! HistoryViewModel).videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.duration
        cell.viewCountLabel.text = video.viewCountString
        
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = (viewModel as! HistoryViewModel).videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}