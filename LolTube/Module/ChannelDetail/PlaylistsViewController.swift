import Foundation
import UIKit

class PlaylistsViewController: SimpleListCollectionViewController {
    
    var channelId:String!
    
    let imageLoadingOperationQueue = NSOperationQueue()
    
    var viewModel:PlaylistsViewModel!
    
    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelPlaylistsEmptyData", comment: "")
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = PlaylistsViewModel(channelId:channelId)
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistsCollectionViewCell.self)
        let playlist = viewModel.playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = playlist.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [unowned self]image in
                let cell = self.collectionView.cell(indexPath, type: PlaylistsCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let playlist = viewModel.playlists[indexPath.row]
        navigationController?.pushViewController(instantiatePlaylistViewController(playlist.playlistId,title:playlist.title), animated: true)
    }
}