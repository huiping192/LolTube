
import Foundation
import UIKit

class ChannelListViewController: SimpleListCollectionViewController {
    var viewModel:ChannelListViewModel!
    fileprivate let imageLoadingOperationQueue = OperationQueue()
    
    override var cellHeight: CGFloat {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            return 80.0
        default:
            return 60.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName:"Channel", viewType:ChannelListViewController.self )
        
        viewModel.refresh(success: {
            [weak self] isDataChanged in
            guard isDataChanged == true else {
                return
            }
            self?.collectionView.reloadEmptyDataSet()
            self?.collectionView.performBatchUpdates({
                [weak self] in
                self?.collectionView.reloadSections(IndexSet(integer: 0))
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
    
    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelVideoEmptyData", comment: "")
    }
        
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = ChannelListViewModel()
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: ChannelCollectionViewCell.self)
        let video = viewModel.channelList[indexPath.row]
        
        cell.titleLabel.text = video.title
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: ChannelCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(_ indexPath: IndexPath){
        let channel = viewModel.channelList[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiateChannelDetailViewController(id:channel.channelId,title:channel.title), animated: true)
    }
}
