import Foundation

class SearchChannelListViewController: SimpleListCollectionViewController,Searchable {
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel where viewModel.searchText != _searchText else {
                return
            }
            viewModel.searchText = _searchText
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
    
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchChannelEmptyData", comment: "")
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = SearchChannelListViewModel()
        viewModel.searchText = _searchText
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: ChannelCollectionViewCell.self)
        let channel = viewModel.channelList[indexPath.row]
        
        cell.titleLabel.text = channel.title
        cell.videoCountLabel.text = channel.videoCountString
        cell.subscriberCountLabel.text = channel.subscriberCountString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = channel.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [unowned self] image in
                let cell = self.collectionView.cell(indexPath, type: ChannelCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        return cell
        
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let channel = viewModel.channelList[indexPath.row]
        navigationController?.pushViewController(instantiateChannelDetailViewController(channel.channelId), animated: true)
    }
}