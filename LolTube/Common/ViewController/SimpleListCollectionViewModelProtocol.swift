import Foundation

protocol SimpleListCollectionViewModelProtocol:class {
    func numberOfItems() -> Int

    func update(success success: (() -> Void), failure: ((error:NSError) -> Void))
}