import Foundation
import UIKit

protocol Reusable {
    static var reuseIdentifier:String {
        get
    }
}

extension UICollectionView {
    func dequeueReusableCell<T:UICollectionViewCell where T:Reusable>(indexPath: NSIndexPath,type:T.Type) -> T{
        return dequeueReusableCellWithReuseIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T:UICollectionReusableView where T:Reusable>(kind:String,indexPath: NSIndexPath,type:T.Type) -> T {
        return dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: T.reuseIdentifier, forIndexPath: indexPath) as! T
    }

}