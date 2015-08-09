import Foundation

protocol SimpleListCollectionViewModelProtocol:class {
        
    func loadedNumberOfItems() -> Int
    
    func allNumberOfItems() -> Int

    func update(success success: (() -> Void), failure: ((error:NSError) -> Void))
}