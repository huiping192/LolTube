import Foundation
import UIKit

class BannerCell:UICollectionViewCell,Reusable {
    @IBOutlet var thunmbnailImageView:UIImageView!
    @IBOutlet var titleLabel:UILabel?
    
    static var reuseId:String {
        return "BannerCell"
    }
}
