import Foundation
import UIKit

protocol Reusable: class {
    static var reuseIdentifier:String {
        get
    }
}

extension UICollectionView {
    func dequeueReusableCell<T:Reusable>(_ indexPath: IndexPath,type:T.Type) -> T{
        return self.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T:Reusable>(_ kind:String,indexPath: IndexPath,type:T.Type) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
    
    func cell<T:UICollectionViewCell>(_ indexPath: IndexPath,type:T.Type) -> T? {
        return cellForItem(at: indexPath).map{$0 as! T}
    }

    func register<T:Reusable>(nibName:String,type:T.Type)  {
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func reloadData(_ completion: @escaping ()->()) {
        reloadData()
        performBatchUpdates({}, completion: {
            _ in
            completion() 
        })
    }
}
