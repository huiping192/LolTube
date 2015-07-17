
import Foundation

class HistoryViewController:SimpleListCollectionViewController {
    
    private let imageLoadingOperationQueue = NSOperationQueue()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.update(success: {
            [unowned self] in
            self.collectionView.performBatchUpdates({
                [unowned self] in
                self.collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: nil)
            },failure:{
                [unowned self]error in
                self.showError(error)
            }
        )
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return HistoryViewModel()
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: HistoryCollectionViewCell.self)
        let video = (viewModel as! HistoryViewModel).videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text =  video.viewCountPublishedAt
        
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [unowned self] image in
            let cell = self.collectionView.cell(indexPath, type: HistoryCollectionViewCell.self)
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