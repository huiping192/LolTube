
import Foundation
import UIKit

class TopVideoCollectionHeaderView:UICollectionReusableView,Reusable {

    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var thumbnailImageView:UIImageView!
    @IBOutlet var moreButton:UIButton!
    
    static var reuseIdentifier:String {
        return "headerView"
    }

}
