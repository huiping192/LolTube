import Foundation

class SearchPlaylistsViewController: SimpleListCollectionViewController,Searchable {
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
    
    var viewModel:SearchPlaylistsViewModel!
    
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override var emptyDataTitle:String{
        return NSLocalizedString("SearchPlaylistEmptyData", comment: "")
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = SearchPlaylistsViewModel()
        viewModel.searchText = _searchText
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistsCollectionViewCell.self)
        let playlist = viewModel.playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        cell.thumbnailImageView.image = nil
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(playlist.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [unowned self] image in
            let cell = self.collectionView.cell(indexPath, type: PlaylistsCollectionViewCell.self)
            cell?.thumbnailImageView.image = image
        }
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let playlist = viewModel.playlists[indexPath.row]
        navigationController?.pushViewController(instantiatePlaylistViewController(playlist.playlistId,title:playlist.title), animated: true)
    }
}
