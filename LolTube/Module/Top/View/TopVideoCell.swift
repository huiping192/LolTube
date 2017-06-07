import Foundation
import UIKit

class TopVideoCell:UICollectionViewCell,Reusable {
    @IBOutlet var thunmbnailImageView:UIImageView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var viewCountLabel:UILabel!
    @IBOutlet var durationLabel:UILabel!
    
    static var reuseId:String {
        return "videoCell"
    }
}
