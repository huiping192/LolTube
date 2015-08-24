
import Foundation
import UIKit

class ChannelListViewController: SimpleListCollectionViewController {
    var viewModel:ChannelListViewModel!
    private let imageLoadingOperationQueue = NSOperationQueue()
    
    override var cellHeight: CGFloat {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Regular, .Regular):
            return 80.0
        default:
            return 60.0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName:"Channel", viewType:ChannelListViewController.self )
    }
    
    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelVideoEmptyData", comment: "")
    }
        
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = ChannelListViewModel()
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
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
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let channel = viewModel.channelList[indexPath.row]
        navigationController?.pushViewController(instantiateChannelDetailViewController(id:channel.channelId,title:channel.title), animated: true)
    }
}