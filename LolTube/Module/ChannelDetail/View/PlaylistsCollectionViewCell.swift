import Foundation
import UIKit


class PlaylistsCollectionViewCell:UICollectionViewCell,Reusable {
    @IBOutlet weak var thumbnailImageView:UIImageView!
    @IBOutlet weak var videoCountLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    
    static var reuseIdentifier:String {
        return "playlistCell"
    }
}