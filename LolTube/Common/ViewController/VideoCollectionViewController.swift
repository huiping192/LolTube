import Foundation

class VideoCollectionViewController: SimpleListCollectionViewController {
    
    override var cellCount: Int {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular) where view.frame.width <= 768:
            return 1
        default:
            return super.cellCount
        }
    }
}
