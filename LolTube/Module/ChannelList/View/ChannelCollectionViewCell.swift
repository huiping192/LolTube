
import Foundation
import UIKit

class ChannelCollectionViewCell:UICollectionViewCell,Reusable {
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    
    static var reuseIdentifier:String {
        return "ChannelCell"
    }
}