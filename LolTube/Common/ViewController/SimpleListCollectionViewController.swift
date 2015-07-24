import Foundation
import UIKit
import DZNEmptyDataSet

protocol SimpleListCollectionViewControllerDelegate:class {
    
    func collectionViewModel() -> SimpleListCollectionViewModelProtocol
    
    func cell(collectionView: UICollectionView,indexPath: NSIndexPath) -> UICollectionViewCell
    
    func didSelectItemAtIndexPath(indexPath: NSIndexPath)
    
    var emptyDataTitle:String{
        get
    }

}

class SimpleListCollectionViewController: UIViewController,SimpleListCollectionViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private weak var delegate: SimpleListCollectionViewControllerDelegate!

    private var _viewModel:SimpleListCollectionViewModelProtocol!
    private var isLoading = false
    
    private var dataLoaded = false

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
    
    func loadData() {
        animateLoadingView()
        
        _viewModel.update(
            success: {
                [unowned self] in
                self.dataLoaded = true
                self.collectionView.alpha = 0.0;
                self.collectionView.setContentOffset(CGPointZero, animated: false)
                self.stopAnimateLoadingView()
                self.collectionView.reloadData()

                dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(0.25) {
                        [unowned self] in
                        self.collectionView.alpha = 1.0;
                    }
                }
            }, failure: {
                [unowned self] error in
                self.showError(error)
                self.stopAnimateLoadingView()
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
        return _viewModel.numberOfItems()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return delegate.cell(collectionView,indexPath:indexPath)
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if shouldLoadNextPageData(){
            loadNextPageData()
        }
    }
    
    private func shouldLoadNextPageData() -> Bool{
        return collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.frame.size.height) * 0.8
    }
    
    private func loadNextPageData(){
        
        let currentVideoCount = collectionView.numberOfItemsInSection(0)
        guard !isLoading &&  currentVideoCount != 0 else {
            return
        }
        
        isLoading = true
        
        _viewModel.update(success: {
            [unowned self] in
            let newVideoCount = self._viewModel.numberOfItems() - currentVideoCount
            guard newVideoCount > 0 else {
                self.isLoading = false
                return
            }
            
            var indexPaths = [NSIndexPath]()
            
            for i in currentVideoCount ..< newVideoCount + currentVideoCount {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.collectionView.performBatchUpdates({
                [unowned self] in
                self.collectionView.insertItemsAtIndexPaths(indexPaths)
                
                }, completion: {
                    [unowned self] _ in
                    self.isLoading = false
                })
            
            },failure:{
                error in
                self.showError(error)
                self.isLoading = false
            }
        )
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    var cellMinWidth: CGFloat {
        return 280.0
    }
    
    var cellHeight: CGFloat {
        return 100.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.size.width as CGFloat
        let cellCount = Int(collectionViewWidth / cellMinWidth)
        let cellWidth = collectionViewWidth / CGFloat(cellCount)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

private class SimpleListCollectionViewModel: SimpleListCollectionViewModelProtocol {
    func numberOfItems() -> Int {
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
        return dataLoaded && _viewModel.numberOfItems() == 0
    }
}