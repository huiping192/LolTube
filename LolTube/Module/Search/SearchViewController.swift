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
    
    @IBOutlet private weak var searchBar:UISearchBar!
    @IBOutlet private weak var searchTypeSegmentedControl:UISegmentedControl!

    
    @IBOutlet private weak var containView:UIView!
    
    private var searchVideoListViewController:SearchVideoListViewController?
    private var searchChannelListViewController:SearchChannelListViewController?
    private var searchPlaylistsViewController:SearchPlaylistsViewController?
    
    private var currentViewController:UIViewController?
    
    private enum SearchType:Int {
        case Video = 0
        case Channel
        case Playlist
    }
    
    private func configureSearchVideoListViewController(searchText:String){
        searchVideoListViewController = configureChildViewController(searchVideoListViewController){
            [unowned self] in
            return self.instantiateSearchVideoListViewController(searchText)
        }
        searchVideoListViewController?.searchText = searchText
    }
    
    private func configureSearchChannelListViewController(searchText:String){
        searchChannelListViewController = configureChildViewController(searchChannelListViewController){
            [unowned self] in
            return self.instantiateSearchChannelListViewController(searchText)
        }
        searchChannelListViewController?.searchText = searchText
    }
    
    private func configureSearchPlaylistsViewController(searchText:String){
        searchPlaylistsViewController = configureChildViewController(searchPlaylistsViewController){
            [unowned self] in
            return self.instantiateSearchPlaylistsViewController(searchText)
        }
        searchPlaylistsViewController?.searchText = searchText
    }
    
    private func configureChildViewController<T:UIViewController>(childViewController:T?,initBlock:(() -> T)) -> T{
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
