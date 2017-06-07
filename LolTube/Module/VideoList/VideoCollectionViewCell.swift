import Foundation

class VideoCellectionViewCell: UICollectionViewCell,Reusable {
    
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var durationLabel:UILabel!
    @IBOutlet weak var viewCountLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var channelLabel:UILabel!
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    static var reuseId:String {
        return "videoCell"
    }
}
