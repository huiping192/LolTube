
import Foundation
import UIKit

class HistoryCollectionViewCell:UICollectionViewCell,Reusable {
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var durationLabel:UILabel!
    @IBOutlet weak var viewCountLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var channelLabel:UILabel!
    
    static var reuseId:String {
        return "historyVideoCell"
    }
}
