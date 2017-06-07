import Foundation
import UIKit
import DZNEmptyDataSet
import Async

protocol SimpleListCollectionViewControllerDelegate:class {
    
    func collectionViewModel() -> SimpleListCollectionViewModelProtocol
    
    func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell
    
    func didSelectItemAtIndexPath(_ indexPath: IndexPath)
    
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
    
    fileprivate weak var delegate: SimpleListCollectionViewControllerDelegate!

    fileprivate var _viewModel: SimpleListCollectionViewModelProtocol!
   
    enum DataSourceState {
        case ready
        case loading
        case partLoaded
        case fullLoaded
        case emptyData
        case loadFailure
    }

    var dataSourceState: DataSourceState = .ready

    var emptyDataTitle:String{
        return ""
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SimpleListCollectionViewController.preferredContentSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        delegate = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        _viewModel = delegate.collectionViewModel()
        loadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let collectionView = collectionView {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    deinit{
        collectionView.emptyDataSetDelegate = nil
        collectionView.emptyDataSetSource = nil
    }
    
    func loadData() {
        dataSourceState = .loading
        startLoadingAnimation()
        _viewModel.update(
            success: {
                [weak self] in
                guard let weakSelf = self else {
                    return
                }
                if weakSelf._viewModel.loadedNumberOfItems() == 0 {
                    weakSelf.dataSourceState = .emptyData
                } else if weakSelf._viewModel.loadedNumberOfItems() == weakSelf._viewModel.allNumberOfItems(){
                    weakSelf.dataSourceState = .fullLoaded
                } else {
                    weakSelf.dataSourceState = .partLoaded
                }
                
                weakSelf.collectionView.alpha = 0.0;
                weakSelf.collectionView.setContentOffset(CGPoint.zero, animated: false)
                weakSelf.stopLoadingAnimation()
                weakSelf.collectionView.reloadData()

                Async.main {
                    UIView.animate(withDuration: 0.25) {
                        [weak self] in
                        self?.collectionView.alpha = 1.0;
                    }
                }
            }, failure: {
                [weak self] error in
                self?.dataSourceState = .loadFailure
                self?.showError(error)
                self?.stopLoadingAnimation()
            })
    }
    
    func preferredContentSizeChanged(_ notification: Notification) {
        collectionView.reloadData()
    }
    
    // MARK : SimpleListCollectionViewControllerDelegate
    func collectionViewModel() -> SimpleListCollectionViewModelProtocol{
        return SimpleListCollectionViewModel()
    }
    
    func cell(_ collectionView: UICollectionView,indexPath: IndexPath) -> UICollectionViewCell{
        return UICollectionViewCell()
    }
    
    func didSelectItemAtIndexPath(_ indexPath: IndexPath){
        
    }
}

extension SimpleListCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemNumber = _viewModel.loadedNumberOfItems()
        return dataSourceState == .partLoaded ? itemNumber + 1 : itemNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return collectionView.dequeueReusableCell(indexPath, type: LoadingCollectionViewCell.self)
        }
        
        return delegate.cell(collectionView,indexPath:indexPath)
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return
        }
        
        delegate.didSelectItemAtIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        guard indexPath.row == _viewModel.loadedNumberOfItems() else {
            return
        }
        loadNextPageData()
    }
    
    fileprivate func loadNextPageData(){
        
        let currentVideoCount = collectionView.numberOfItems(inSection: 0) - 1
        guard dataSourceState != .loading &&  currentVideoCount != 0 else {
            return
        }
        
        dataSourceState = .loading
        
        _viewModel.update(success: {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.dataSourceState = weakSelf._viewModel.loadedNumberOfItems() == weakSelf._viewModel.allNumberOfItems() ? .fullLoaded : .partLoaded
            
            let newVideoCount = weakSelf._viewModel.loadedNumberOfItems() - currentVideoCount
            guard newVideoCount > 0 else {                
                return
            }
            
            var indexPaths = [IndexPath]()
            
            for i in currentVideoCount ..< newVideoCount + currentVideoCount {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            let deleteIndexPaths = [IndexPath(row: currentVideoCount, section: 0)]
            
            weakSelf.collectionView.performBatchUpdates({
                [weak self] in
                if self?.dataSourceState == .fullLoaded {
                    self?.collectionView.deleteItems(at: deleteIndexPaths)
                }
                
                self?.collectionView.insertItems(at: indexPaths)

                }, completion: {
                    [weak self] _ in
                    self?.dataSourceState = .partLoaded
                })
            
            },failure:{
                [weak self]error in
                self?.showError(error)
                self?.dataSourceState = .loadFailure
            }
        )
    }
}

extension SimpleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    var cellHeight: CGFloat {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            return 120.0
        default:
            return 100.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.row != _viewModel.loadedNumberOfItems() else {
            return CGSize(width: collectionView.frame.width, height: 60.0)
        }
        
        let collectionViewWidth = collectionView.frame.size.width as CGFloat
        let cellWidth = collectionViewWidth / CGFloat(cellCount)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    var cellCount: Int {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
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
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)){
        
    }
}

extension SimpleListCollectionViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView:UIScrollView!) -> UIImage! {
        return UIImage(named: "Empty_Data")
    }
    
    func title(forEmptyDataSet scrollView:UIScrollView!) -> NSAttributedString! {
        let text = emptyDataTitle
        let attributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18),NSForegroundColorAttributeName:UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

extension SimpleListCollectionViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView:UIScrollView!) -> Bool{
        return dataSourceState == .emptyData
    }
}


extension SimpleListCollectionViewController {
    override func fetchNewData(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        _viewModel.update(success: {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData(){
                completionHandler(.newData) 
            }
            }, failure: {
                _ in
                completionHandler(.failed)
            })
        
    }
}
