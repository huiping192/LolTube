import Foundation
import UIKit

protocol Searchable: class {
    var searchText:String{
        get
        set
    }
}

class SearchViewController: UIViewController {
    
    @IBOutlet fileprivate weak var searchSuggestionView:UIView!
    @IBOutlet fileprivate weak var searchContentView:UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet fileprivate weak var searchTypeSegmentedControl:UISegmentedControl!
    
    @IBOutlet fileprivate weak var containView:UIView!
    
    fileprivate var searchVideoListViewController:SearchVideoListViewController?
    fileprivate var searchChannelListViewController:SearchChannelListViewController?
    fileprivate var searchPlaylistsViewController:SearchPlaylistsViewController?
    
    fileprivate var currentViewController:UIViewController?
    
    fileprivate var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTypeSegmentedControl.setTitle(NSLocalizedString("Video", comment: ""), forSegmentAt: 0)
        searchTypeSegmentedControl.setTitle(NSLocalizedString("Channel", comment: ""), forSegmentAt: 1)
        searchTypeSegmentedControl.setTitle(NSLocalizedString("Playlist", comment: ""), forSegmentAt: 2)

        
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            navigationItem.title = NSLocalizedString("Search", comment: "")
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 260, height: 44.0))
            searchBar.delegate = self
            searchBar.searchBarStyle = .minimal
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
            self.searchBar = searchBar
        } else {
            searchController.searchBar.delegate = self
            searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
            searchController.searchBar.searchBarStyle = .minimal
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
            self.searchBar = searchController.searchBar
            //fix UISearchController makes the controller black bug
            definesPresentationContext = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventTracker.trackViewContentView(viewName:"Search", viewType:SearchViewController.self )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: {
            [weak self]_ in
            self?.searchVideoListViewController?.collectionView.collectionViewLayout.invalidateLayout()
            self?.searchChannelListViewController?.collectionView.collectionViewLayout.invalidateLayout()
            self?.searchPlaylistsViewController?.collectionView.collectionViewLayout.invalidateLayout()

        }, completion: nil)
    }
    
    fileprivate enum SearchType:Int {
        case video = 0
        case channel
        case playlist
    }
    
    fileprivate func configureSearchVideoListViewController(_ searchText:String){
        searchVideoListViewController = configureChildViewController(searchVideoListViewController){
            return ViewControllerFactory.instantiateSearchVideoListViewController(searchText)
        }
        searchVideoListViewController?.searchText = searchText
    }
    
    fileprivate func configureSearchChannelListViewController(_ searchText:String){
        searchChannelListViewController = configureChildViewController(searchChannelListViewController){
            return ViewControllerFactory.instantiateSearchChannelListViewController(searchText)
        }
        searchChannelListViewController?.searchText = searchText
    }
    
    fileprivate func configureSearchPlaylistsViewController(_ searchText:String){
        searchPlaylistsViewController = configureChildViewController(searchPlaylistsViewController){
            return ViewControllerFactory.instantiateSearchPlaylistsViewController(searchText)
        }
        searchPlaylistsViewController?.searchText = searchText
    }
    
    fileprivate func configureChildViewController<T:UIViewController>(_ childViewController:T?,initBlock: (() -> T)) -> T{
        let realChildViewController = childViewController ?? initBlock()
        swapToChildViewController(realChildViewController)
        return realChildViewController
    }
    
    fileprivate func swapToChildViewController(_ childViewController:UIViewController){
        if let currentViewController = currentViewController {
            removeViewController(currentViewController)
        }
        
        addConstraintsForViewController(childViewController)
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
        currentViewController = childViewController
    }
    
    fileprivate func removeViewController(_ viewController:UIViewController?){
        guard let viewController = viewController else {
            return
        }
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    fileprivate func addConstraintsForViewController(_ viewController:UIViewController){
        let childView = viewController.view
        childView?.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(childView!)
        containView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
        containView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["childView":childView] as [String:AnyObject]))
    }
    
    @IBAction func segmentedControlValueChanged(_ segmentedControl:UISegmentedControl) {
        searchBar.resignFirstResponder()

        guard let searchText = searchBar.text , let searchType = SearchType(rawValue:segmentedControl.selectedSegmentIndex) else {
            return
        }
        switch searchType {
        case .video:
            configureSearchVideoListViewController(searchText)
        case .channel:
            configureSearchChannelListViewController(searchText)
        case .playlist:
            configureSearchPlaylistsViewController(searchText)
        }
    }
    
    @IBAction func suggestionWardTapped(_ suggestionWardButton:UIButton) {
        searchBar.resignFirstResponder()
        let searchText = suggestionWardButton.title(for: UIControlState())
        searchBar.text = searchText
        search(searchText)
    }
    
    fileprivate func search(_ searchText:String?){
        guard let searchText = searchText else {
            return
        }
        
        EventTracker.trackSearch(searchText)
        
        searchSuggestionView.alpha = 0.0
        searchContentView.alpha = 1.0
        
        if self.currentViewController == nil {
            configureSearchVideoListViewController(searchText)
        }
        
        var childVcs:[UIViewController?] = [searchVideoListViewController,searchChannelListViewController,searchPlaylistsViewController]
        childVcs.map{$0 as? Searchable}.forEach{
            (searchable) -> Void in
            searchable?.searchText = searchText
        }
    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        search(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
