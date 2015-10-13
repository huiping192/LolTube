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
    
    func cell<T:UICollectionViewCell where T:Reusable>(indexPath: NSIndexPath,type:T.Type) -> T?{
        return cellForItemAtIndexPath(indexPath).map{$0 as! T}
    }

    func register<T:UICollectionViewCell where T:Reusable>(nibName nibName:String,type:T.Type) {
        registerNib(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func reloadData(completion: ()->()) {
        reloadData()
        performBatchUpdates({}, completion: {
            _ in
            completion() 
        })
    }
}