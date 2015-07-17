import Foundation

class PlaylistViewController: SimpleListCollectionViewController {
    
    var playlistId:String!
    var playlistTitle:String!
    
    private let imageLoadingOperationQueue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = playlistTitle
    }
    
    override func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return PlaylistViewModel(playlistId: playlistId)
    }
    
    override func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(indexPath, type: PlaylistCollectionViewCell.self)
        let video = (viewModel as! PlaylistViewModel).videoList[indexPath.row]
        
        cell.videoNumberLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = video.title
        cell.channelLabel.text = video.channelTitle
        cell.durationLabel.text = video.durationString
        cell.viewCountLabel.text = video.viewCountPublishedAt
        
        let imageOperation = UIImageView.asynLoadingImageWithUrlString(video.thumbnailUrl, secondImageUrlString: nil, needBlackWhiteEffect: false) {
            [unowned self] image in
            let cell = self.collectionView.cell(indexPath, type: PlaylistCollectionViewCell.self)
            cell?.thumbnailImageView.image = image
        }
        
        imageLoadingOperationQueue.addOperation(imageOperation)
        
        return cell
    }
    
    override func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        let cellVo = (viewModel as! PlaylistViewModel).videoList[indexPath.row]
        navigationController?.pushViewController(instantiateVideoDetailViewController(cellVo.videoId), animated: true)
    }
}