import Foundation
import UIKit

protocol Reusable: class {
    static var reuseId:String {
        get
    }
}

extension UICollectionView {
    func dequeueReusableCell<T:UICollectionViewCell>(_ indexPath: IndexPath,type:T.Type) -> T where T:Reusable{
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseId, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T:UICollectionReusableView>(_ kind:String,indexPath: IndexPath,type:T.Type) -> T where T:Reusable {
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseId, for: indexPath) as! T
    }
    
    func cell<T:UICollectionViewCell>(_ indexPath: IndexPath,type:T.Type) -> T? where T:Reusable{
        return cellForItem(at: indexPath).map{$0 as! T}
    }

    func register<T:UICollectionViewCell>(nibName:String,type:T.Type) where T:Reusable {
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: T.reuseId)
    }
    
    func reloadData(_ completion: @escaping ()->()) {
        reloadData()
        performBatchUpdates({}, completion: {
            _ in
            completion() 
        })
    }
}
