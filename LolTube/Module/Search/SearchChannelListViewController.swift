import Foundation

class SearchChannelListViewController: SimpleListCollectionViewController,Searchable {
    fileprivate var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel, viewModel.searchText != _searchText else {
                return
            }
            viewModel.searchText = _searchText
            self.collectionView.alpha = 0.0;
            super.loadData()
        }
    }
    
    var searchText:String{
        get{
            return _searchText
        }
        set{
            _searchText = newValue
        }
    }
    
    var viewModel:SearchChannelListViewModel!
    
    let imageLoadingOperationQueue = OperationQueue()
    
    override var cellHeight: CGFloat {
        return 85.0
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchChannelEmptyData", comment: "")
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = SearchChannelListViewModel()
        viewModel.searchText = _searchText
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell( indexPath, type: SearchChannelCollectionViewCell.self)
        let channel = viewModel.channelList[indexPath.row]
        
        cell.titleLabel.text = channel.title
        cell.videoCountLabel.text = channel.videoCountString
        cell.subscriberCountLabel.text = channel.subscriberCountString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = channel.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak collectionView] image in
                let cell = collectionView?.cell(indexPath, type: SearchChannelCollectionViewCell.self)
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
