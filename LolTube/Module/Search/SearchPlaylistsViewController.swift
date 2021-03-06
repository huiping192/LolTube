import Foundation

class SearchPlaylistsViewController: SimpleListCollectionViewController,Searchable {
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
    
    var viewModel:SearchPlaylistsViewModel!
    
    let imageLoadingOperationQueue = OperationQueue()
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchPlaylistEmptyData", comment: "")
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = SearchPlaylistsViewModel()
        viewModel.searchText = _searchText
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistsCollectionViewCell.self)
        let playlist = viewModel.playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = playlist.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: PlaylistsCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        return cell
    }
    
    override func didSelectItemAtIndexPath(_ indexPath: IndexPath){
        let playlist = viewModel.playlists[indexPath.row]
        navigationController?.pushViewController(ViewControllerFactory.instantiatePlaylistViewController(playlist.playlistId,title:playlist.title), animated: true)
    }
}
