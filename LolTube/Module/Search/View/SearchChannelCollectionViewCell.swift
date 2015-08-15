import Foundation
import UIKit

class SearchChannelCollectionViewCell:UICollectionViewCell,Reusable {
    
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var videoCountLabel:UILabel!
    @IBOutlet weak var subscriberCountLabel:UILabel!
    
    static var reuseIdentifier:String {
        return "channelCell"
    }
}
