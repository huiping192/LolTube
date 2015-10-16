import Foundation
import UIKit
import DZNEmptyDataSet
import Async

protocol SimpleListCollectionViewControllerDelegate:class {
    
    func collectionViewModel() -> SimpleListCollectionViewModelProtocol
    
    func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell
    
    func didSelectItemAtIndexPath(indexPath: NSIndexPath)
    
    var emptyDataTitle:String{
        get
    }

}

class SimpleListCollectionViewController: UIViewController,SimpleListCollectionViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(nibName: "LoadingCollectionViewCell", type: LoadingCollectionViewCell.self)
        }
    }
    
    private weak var delegate: SimpleListCollectionViewControllerDelegate!

    private var _viewModel: SimpleListCollectionViewModelProtocol!
   
    enum DataSourceState {
        case Ready
        case Loading
        case PartLoaded
        case FullLoaded
        case EmptyData
        case LoadFailure
    }

    var dataSourceState: DataSourceState = .Ready

    var emptyDataTitle:String{
        return ""
    }
    
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        delegate = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        _viewModel = delegate.collectionViewModel()
        loadData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let collectionView = collectionView {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    deinit{
        collectionView.emptyDataSetDelegate = nil
        collectionView.emptyDataSetSource = nil
    }
    
    func loadData() {
        dataSourceState = .Loading
        startLoadingAnimation()
        _viewModel.update(
            success: {
                [weak self] in
                guard let weakSelf = self else {
                    return
                }
                if weakSelf._viewModel.loadedNumberOfItems() == 0 {
                    weakSelf.dataSourceState = .EmptyData
                } else if weakSelf._viewModel.loadedNumberOfItems() == weakSelf._viewModel.allNumberOfItems(){
                    weakSelf.dataSourceState = .FullLoaded
                } else {
                    weakSelf.dataSourceState = .PartLoaded
                }
                
                weakSelf.collectionView.alpha = 0.0;
                weakSelf.collectionView.setContentOffset(CGPointZero, animated: false)
                weakSelf.stopLoadingAnimation()
                weakSelf.collectionView.reloadData()

                Async.main {
                    UIView.animateWithDuration(0.25) {
                        [weak self] in
                        self?.collectionView.alpha = 1.0;
                    }
                }
            }, failure: {
                [weak self] error in
                self?.dataSourceState = .LoadFailure
                self?.showError(error)
                self?.stopLoadingAnimation()
            })
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        collectionView.reloadData()
    }
    
    // MARK : SimpleListCollectionViewControllerDelegate
    func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return SimpleListCollectionViewModel()
    }
    
    func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell{
        return UICollectionViewCell()
    }
    
    func didSelectItemAtIndexPath(indexPath: NSIndexPath){
        
    }
}

extension SimpleListCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemNumber = _viewModel.loadedNumberOfItems()
        return dataSourceState == .PartLoaded ? itemNumber + 1 : itemNumber
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return collectionView.dequeueReusableCell(indexPath, type: LoadingCollectionViewCell.self)
        }
        
        return delegate.cell(collectionView,indexPath:indexPath)
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return
        }
        
        delegate.didSelectItemAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = nil
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath){
        guard indexPath.row == _viewModel.loadedNumberOfItems() else {
            return
        }
        loadNextPageData()
    }
    
    private func loadNextPageData(){
        
        let currentVideoCount = collectionView.numberOfItemsInSection(0) - 1
        guard dataSourceState != .Loading &&  currentVideoCount != 0 else {
            return
        }
        
        dataSourceState = .Loading
        
        _viewModel.update(success: {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.dataSourceState = weakSelf._viewModel.loadedNumberOfItems() == weakSelf._viewModel.allNumberOfItems() ? .FullLoaded : .PartLoaded
            
            let newVideoCount = weakSelf._viewModel.loadedNumberOfItems() - currentVideoCount
            guard newVideoCount > 0 else {                
                return
            }
            
            var indexPaths = [NSIndexPath]()
            
            for i in currentVideoCount ..< newVideoCount + currentVideoCount {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            let deleteIndexPaths = [NSIndexPath(forRow: currentVideoCount, inSection: 0)]
            
            weakSelf.collectionView.performBatchUpdates({
                [weak self] in
                if self?.dataSourceState == .FullLoaded {
                    self?.collectionView.deleteItemsAtIndexPaths(deleteIndexPaths)
                }
                
                self?.collectionView.insertItemsAtIndexPaths(indexPaths)

                }, completion: {
                    [weak self] _ in
                    self?.dataSourceState = .PartLoaded
                })
            
            },failure:{
                [weak self]error in
                self?.showError(error)
                self?.dataSourceState = .LoadFailure
            }
        )
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    var cellHeight: CGFloat {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Regular, .Regular):
            return 120.0
        default:
            return 100.0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return CGSize(width: collectionView.frame.width, height: 60.0)
        }
        
        let collectionViewWidth = collectionView.frame.size.width as CGFloat
        let cellWidth = collectionViewWidth / CGFloat(cellCount)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    var cellCount: Int {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.Compact, .Regular):
            return 1
        default:
            return 2
        }

    }
}

private class SimpleListCollectionViewModel: SimpleListCollectionViewModelProtocol {
    func loadedNumberOfItems() -> Int {
        return 0
    }
    
    func allNumberOfItems() -> Int {
        return 0
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        
    }
}

extension SimpleListCollectionViewController: DZNEmptyDataSetSource {
    func imageForEmptyDataSet(scrollView:UIScrollView!) -> UIImage! {
        return UIImage(named: "Empty_Data")
    }
    
    func titleForEmptyDataSet(scrollView:UIScrollView!) -> NSAttributedString! {
        let text = emptyDataTitle
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18),NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

extension SimpleListCollectionViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(scrollView:UIScrollView!) -> Bool{
        return dataSourceState == .EmptyData
    }
}


extension SimpleListCollectionViewController {
    override func fetchNewData(completionHandler: (UIBackgroundFetchResult) -> Void) {
        _viewModel.update(success: {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData(){
                completionHandler(.NewData) 
            }
            }, failure: {
                _ in
                completionHandler(.Failed)
            })
        
    }
}