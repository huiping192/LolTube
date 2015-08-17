import Foundation

class PlaylistViewController: VideoCollectionViewController {
    
    var playlistId:String!
    var playlistTitle:String!
    
    var viewModel:PlaylistViewModel!
    
    private let imageLoadingOperationQueue = NSOperationQueue()

    override var emptyDataTitle:String{
        return NSLocalizedString("ChannelPlaylistEmptyData", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = playlistTitle
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        viewModel = PlaylistViewModel(playlistId: playlistId)
        return viewModel
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistCollectionViewCell.self)
        let video = viewModel.videoList[indexPath.row]
        
        cell.videoNumberLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        cell.thumbnailImageView.image = nil
        if let thumbnailUrl = video.thumbnailUrl {
            let imageOperation = ImageLoadOperation(url:thumbnailUrl){
                [weak self] image in
                let cell = self?.collectionView.cell(indexPath, type: PlaylistCollectionViewCell.self)
                cell?.thumbnailImageView.image = image
            }
            imageLoadingOperationQueue.addOperation(imageOperation)
        }
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let cellVo = viewModel.videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(cellVo.videoId), animated: true)
    }
}
