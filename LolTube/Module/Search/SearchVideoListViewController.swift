import Foundation

class SearchVideoListViewController: VideoCollectionViewController,Searchable {
    
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel where viewModel.searchText != _searchText  else {
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
    
    var viewModel:SearchVideoListViewModel!
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchVideoEmptyData", comment: "")
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = SearchVideoListViewModel()
        viewModel.searchText = _searchText
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(indexPath, type: VideoCellectionViewCell.self)

        let video = viewModel.videoList[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: VideoCellectionViewCell.self)
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
