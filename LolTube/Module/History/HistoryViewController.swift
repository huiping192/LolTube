
import Foundation

class HistoryViewController:VideoCollectionViewController {
    
    private let imageLoadingOperationQueue = NSOperationQueue()

    var viewModel:HistoryViewModel!
    
    override var emptyDataTitle:String{
        return NSLocalizedString("HistoryEmptyData", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        EventTracker.trackViewContentView(viewName:"History", viewType:TopViewController.self )

        viewModel.refresh(success: {
            [weak self] isDataChanged in
            guard isDataChanged == true else {
                return
            }
            self?.collectionView.reloadEmptyDataSet()
            self?.collectionView.performBatchUpdates({
                [weak self] in
                self?.collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: nil)
            },failure:{
                [weak self]error in
                self?.showError(error)
            }
        )
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = HistoryViewModel()
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: HistoryCollectionViewCell.self)
        let video = viewModel.videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text =  video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: HistoryCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiateVideoDetailViewController(video.videoId), animated: true)
    }
}