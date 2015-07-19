import Foundation

class SearchChannelListViewController: SimpleListCollectionViewController,Searchable {
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel as? SearchChannelListViewModel where viewModel.searchText != _searchText else {
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
    
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        let searchChannelListViewModel = SearchChannelListViewModel()
        searchChannelListViewModel.searchText = _searchText
        return searchChannelListViewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: ChannelCollectionViewCell.self)
        let channel = (viewModel as! SearchChannelListViewModel).channelList[indexPath.row]
        
        cell.titleLabel.text = channel.title
        cell.videoCountLabel.text = channel.videoCountString
        cell.subscriberCountLabel.text = channel.subscriberCountString
        
        cell.thumbnailImageView.image = nil
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(channel.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
        
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let channel = (viewModel as! SearchChannelListViewModel).channelList[indexPath.row]
        navigationController?.pushViewController(instantiateChannelDetailViewController(channel.channelId), animated: true)
    }
}