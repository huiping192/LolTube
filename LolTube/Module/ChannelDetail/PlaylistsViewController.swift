import Foundation
import UIKit

class PlaylistsViewController: SimpleListCollectionViewController {
    
    var channelId:String!
    var channelTitle:String!
    
    let imageLoadingOperationQueue = OperationQueue()
    
    var viewModel:PlaylistsViewModel!
    
    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelPlaylistsEmptyData", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName: "Channel Playlist", viewType: PlaylistsViewController.self, viewId: channelTitle)
    }
    
    deinit{
        imageLoadingOperationQueue.cancelAllOperations()
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = PlaylistsViewModel(channelId:channelId)
        return viewModel
    }
    
    override func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell( indexPath, type: PlaylistsCollectionViewCell.self)
        let playlist = viewModel.playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = playlist.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self]image in
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
