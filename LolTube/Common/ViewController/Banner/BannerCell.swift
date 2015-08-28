import Foundation
import UIKit

class BannerCell:UICollectionViewCell,Reusable {
    @IBOutlet var thunmbnailImageView:UIImageView!
    @IBOutlet var titleLabel:UILabel?
    
    static var reuseIdentifier:String {
        return "BannerCell"
    }
}