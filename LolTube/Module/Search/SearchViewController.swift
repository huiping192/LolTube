import Foundation
import UIKit

protocol Searchable {
    var searchText:String{
        get
        set
    }
}

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var searchSuggestionView:UIView!
    @IBOutlet private weak var searchContentView:UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet private weak var searchTypeSegmentedControl:UISegmentedControl!
    
    @IBOutlet private weak var containView:UIView!
    
    private var searchVideoListViewController:SearchVideoListViewController?
    private var searchChannelListViewController:SearchChannelListViewController?
    private var searchPlaylistsViewController:SearchPlaylistsViewController?
    
    private var currentViewController:UIViewController?
    
    private var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.horizontalSizeClass == .Regular && traitCollection.verticalSizeClass == .Regular {
            navigationItem.title = NSLocalizedString("Search", comment: "")
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 260, height: 44.0))
            searchBar.delegate = self
            searchBar.searchBarStyle = .Minimal
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
            self.searchBar = searchBar
        } else {
            searchController.searchBar.delegate = self
            searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
            searchController.searchBar.searchBarStyle = .Minimal
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
            self.searchBar = searchController.searchBar
            //fix UISearchController makes the controller black bug
            definesPresentationContext = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName:"Search", viewType:SearchViewController.self )
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({
            [weak self]_ in
            self?.searchVideoListViewController?.collectionView.collectionViewLayout.invalidateLayout()
            self?.searchChannelListViewController?.collectionView.collectionViewLayout.invalidateLayout()
            self?.searchPlaylistsViewController?.collectionView.collectionViewLayout.invalidateLayout()

        }, completion: nil)
    }
    
    private enum SearchType:Int {
        case Video = 0
        case Channel
        case Playlist
    }
    
    private func configureSearchVideoListViewController(searchText:String){
        searchVideoListViewController = configureChildViewController(searchVideoListViewController){
            return self.instantiateSearchVideoListViewController(searchText)
        }
        searchVideoListViewController?.searchText = searchText
    }
    
    private func configureSearchChannelListViewController(searchText:String){
        searchChannelListViewController = configureChildViewController(searchChannelListViewController){
            return self.instantiateSearchChannelListViewController(searchText)
        }
        searchChannelListViewController?.searchText = searchText
    }
    
    private func configureSearchPlaylistsViewController(searchText:String){
        searchPlaylistsViewController = configureChildViewController(searchPlaylistsViewController){
            return self.instantiateSearchPlaylistsViewController(searchText)
        }
        searchPlaylistsViewController?.searchText = searchText
    }
    
    private func configureChildViewController<T:UIViewController>(childViewController:T?,@noescape initBlock:(() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
    }
    
    private func swapToChildViewController(childViewController:UIViewController){
        if let currentViewController = currentViewController {
            removeViewController(currentViewController)
        }
        
        addConstraintsForViewController(childViewController)
        addChildViewController(childViewController)
        childViewController.didMoveToParentViewController(self)
        currentViewController = childViewController
    }
    
    private func removeViewController(viewController:UIViewController?){
        guard let viewController = viewController else {
            return
        }
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    private func addConstraintsForViewController(viewController:UIViewController){
        let childView = viewController.view
        childView.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(childView)
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
        containView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
    }
    
    @IBAction func segmentedControlValueChanged(segmentedControl:UISegmentedControl) {
        searchBar.resignFirstResponder()

        guard let searchText = searchBar.text , let searchType = SearchType(rawValue:segmentedControl.selectedSegmentIndex) else {
            return
        }
        switch searchType {
        case .Video:
            configureSearchVideoListViewController(searchText)
        case .Channel:
            configureSearchChannelListViewController(searchText)
        case .Playlist:
            configureSearchPlaylistsViewController(searchText)
        }
    }
    
    @IBAction func suggestionWardTapped(suggestionWardButton:UIButton) {
        searchBar.resignFirstResponder()

        let searchText = suggestionWardButton.titleForState(.Normal)!
        
        searchBar.text = searchText
        
        searchSuggestionView.alpha = 0.0
        searchContentView.alpha = 1.0
        
        if self.currentViewController == nil {
            configureSearchVideoListViewController(searchText)
        }
        
        var currentViewController = self.currentViewController as? Searchable
        currentViewController!.searchText = searchText
    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        guard let searchText = searchBar.text else {
            return
        }
        EventTracker.trackSearch(searchText)
        
        searchSuggestionView.alpha = 0.0
        searchContentView.alpha = 1.0
        
        if self.currentViewController == nil {
            configureSearchVideoListViewController(searchText)
        }
        
        var currentViewController = self.currentViewController as? Searchable
        currentViewController!.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.text = nil
        
        searchSuggestionView.alpha = 1.0
        searchContentView.alpha = 0.0
        
        searchTypeSegmentedControl.selectedSegmentIndex = 0
        
        searchVideoListViewController = nil
        searchChannelListViewController = nil
        searchPlaylistsViewController = nil
        
        removeViewController(currentViewController)
        currentViewController = nil
    }
}
