import Foundation
import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell,Reusable {
    @IBOutlet weak var videoNumberLabel:UILabel!

    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var durationLabel:UILabel!
    @IBOutlet weak var viewCountLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var channelLabel:UILabel!
 
    
    static var reuseId:String {
        return "playlistCollectionViewCell"
    }
}
