import Foundation

protocol SimpleListCollectionViewModelProtocol:class {
        
    func loadedNumberOfItems() -> Int
    
    func allNumberOfItems() -> Int

    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void))
}
