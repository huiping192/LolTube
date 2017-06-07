
import Foundation
import UIKit

class TopVideoCollectionHeaderView:UICollectionReusableView,Reusable {

    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var thumbnailImageView:UIImageView!
    @IBOutlet var moreButton:UIButton!
    
    static var reuseId:String {
        return "headerView"
    }

}
