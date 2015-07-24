import Foundation

class SearchVideoListViewController: SimpleListCollectionViewController,Searchable {
    
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel where viewModel.searchText != _searchText  else {
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
    
    var viewModel:SearchVideoListViewModel!
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchVideoEmptyData", comment: "")
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
        cell.durationLabel.text = video.duration
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [unowned self] image in
            let cell = self.collectionView.cell(indexPath, type: VideoCellectionViewCell.self)
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let video = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(video.videoId), animated: true)
    }
    
}
