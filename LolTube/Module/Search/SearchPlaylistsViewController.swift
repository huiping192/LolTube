import Foundation

class SearchPlaylistsViewController: SimpleListCollectionViewController,Searchable {
    private var _searchText:String!{
        didSet{
            guard let viewModel =  viewModel as? SearchPlaylistsViewModel where viewModel.searchText != _searchText else {
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
        let searchPlaylistsViewModel = SearchPlaylistsViewModel()
        searchPlaylistsViewModel.searchText = _searchText
        return searchPlaylistsViewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistsCollectionViewCell.self)
        let playlist = (viewModel as! SearchPlaylistsViewModel).playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        cell.thumbnailImageView.image = nil
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(playlist.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let playlist = (viewModel as! SearchPlaylistsViewModel).playlists[indexPath.row]
        navigationController?.pushViewController(instantiatePlaylistViewController(playlist.playlistId,title:playlist.title), animated: true)
    }
}
