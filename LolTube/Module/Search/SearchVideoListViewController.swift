import Foundation

class SearchVideoListViewController: SimpleListCollectionViewController,Searchable {
    
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel as? SearchVideoListViewModel where viewModel.searchText != _searchText  else {
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
        let searchVideoListViewModel = SearchVideoListViewModel()
        searchVideoListViewModel.searchText = _searchText
        return searchVideoListViewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(indexPath, type: VideoCellectionViewCell.self)

        let video = (viewModel as! SearchVideoListViewModel).videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.duration
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = (viewModel as! SearchVideoListViewModel).videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
    
}