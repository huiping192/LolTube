
import Foundation
import UIKit

class VideoRelatedVideoCell: UICollectionViewCell,Reusable {
    
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var durationLabel:UILabel!
    @IBOutlet weak var viewCountLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var channelLabel:UILabel!
    
    static var reuseIdentifier:String {
        return "videoCell"
    }
}
