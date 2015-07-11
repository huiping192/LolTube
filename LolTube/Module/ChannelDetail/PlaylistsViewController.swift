import Foundation
import UIKit

class PlaylistsViewController: SimpleListCollectionViewController {
    
    var channelId:String!
    
    let imageLoadingOperationQueue = NSOperationQueue()
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return PlaylistsViewModel(channelId:channelId)
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playlistCell", forIndexPath: indexPath) as! PlaylistsCollectionViewCell
        let playlist = (viewModel as! PlaylistsViewModel).playlists[indexPath.row]
        
        cell.titleLabel.text = playlist.title
        cell.videoCountLabel.text = playlist.videoCountString
        
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(playlist.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [weak cell] image in
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let playlist = (viewModel as! PlaylistsViewModel).playlists[indexPath.row]
        navigationController?.pushViewController(instantiatePlaylistViewController(playlist.playlistId,title:playlist.title), animated: true)
    }
}