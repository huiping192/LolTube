import Foundation

extension UIViewController {
    private enum StoryboardName:String {
        case ChannelDetail = "ChannelDetail"
        case VideoList = "VideoList"
        case Search = "Search"
        case Main = "Main"
        case Banner = "Banner"
    }
    
    private enum ViewControllerIdentifier:String {
        case playlist = "playlist"
        case videoDetail = "videoDetail"
        case playlists = "playlists"
        case channelInfo = "channelInfo"
        
        // search child view controllers
        case SearchVideoList = "SearchVideoList"
        case SearchChannelList = "SearchChannelList"
        case SearchPlaylists = "SearchPlaylists"
        
        // banner
        case SplitBanner = "SplitBanner"
        case CombinedBanner = "CombinedBanner"
        
    }
    
    func instantiateChannelDetailViewController(id id:String,title:String?) -> ChannelDetailViewController{
        let channelDetailViewController = viewController(.ChannelDetail, type: ChannelDetailViewController.self)
        channelDetailViewController.channelId = id
        channelDetailViewController.channelTitle = title

        return channelDetailViewController
    }
    
    func instantiateVideoListViewController(channelId:String,channelTitle:String) -> VideoListViewController{
        let videoListViewController = viewController(.VideoList, type: VideoListViewController.self)
        videoListViewController.channelId = channelId
        videoListViewController.channelTitle = channelTitle
        return videoListViewController
    }
    
    func instantiatePlaylistsViewController(channelId:String,channelTitle:String) -> PlaylistsViewController{
        let playlistsViewController = viewController(.ChannelDetail,viewControllerId:.playlists, type: PlaylistsViewController.self)
        
        playlistsViewController.channelId = channelId
        playlistsViewController.channelTitle = channelTitle

        return playlistsViewController
    }
    
    func instantiateChannelInfoViewController(description:String,channelId:String,channelTitle:String) -> ChannelInfoViewController{
        
        let channelInfoViewController = viewController(.ChannelDetail,viewControllerId:.channelInfo, type: ChannelInfoViewController.self)
        
        channelInfoViewController.channelTitle = channelTitle
        channelInfoViewController.channelId = channelId
        channelInfoViewController.channelDescription = description
        
        return channelInfoViewController
    }
    
    func instantiateVideoDetailViewController(videoId:String) -> RSVideoDetailViewController{
        let videoDetailViewController = viewController(.Main,viewControllerId:.videoDetail, type: RSVideoDetailViewController.self)
        
        videoDetailViewController.videoId = videoId
        return videoDetailViewController
    }
    
    func instantiatePlaylistViewController(playlistId:String,title:String?) ->  PlaylistViewController{
        let playlistViewController = viewController(.ChannelDetail,viewControllerId:.playlist, type: PlaylistViewController.self)
        
        playlistViewController.playlistId = playlistId
        playlistViewController.playlistTitle = title
        
        return playlistViewController
    }
    
    func instantiateSearchVideoListViewController(searchText:String) ->  SearchVideoListViewController{
        let searchVideoListViewController = viewController(.Search,viewControllerId:.SearchVideoList, type: SearchVideoListViewController.self)
        
        searchVideoListViewController.searchText = searchText
        
        return searchVideoListViewController
    }
    
    func instantiateSearchChannelListViewController(searchText:String) ->  SearchChannelListViewController{
        let searchChannelListViewController = viewController(.Search,viewControllerId:.SearchChannelList, type: SearchChannelListViewController.self)
        
        searchChannelListViewController.searchText = searchText
        
        return searchChannelListViewController
    }
    
    func instantiateSearchPlaylistsViewController(searchText:String) ->  SearchPlaylistsViewController{
        let searchPlaylistsViewController = viewController(.Search,viewControllerId:.SearchPlaylists, type: SearchPlaylistsViewController.self)
        
        searchPlaylistsViewController.searchText = searchText
        
        return searchPlaylistsViewController
    }
    
    func instantiateBannerViewController(videoList:[Video]) ->  BannerViewController{
        let bannerViewController = viewController(.Banner, type: BannerViewController.self)
        
        bannerViewController.videoList = videoList
        
        return bannerViewController
    }
    
    func instantiateSplitBannerViewController(videoList:[Video]) ->  SplitBannerViewController{
        let bannerViewController = viewController(.Banner,viewControllerId:.SplitBanner, type: SplitBannerViewController.self)
        
        bannerViewController.videoList = videoList
        
        return bannerViewController
    }
    
    func instantiateCombinedBannerViewController(videoList:[Video]) ->  CombinedBannerViewController{
        let bannerViewController = viewController(.Banner,viewControllerId:.CombinedBanner, type: CombinedBannerViewController.self)
        
        bannerViewController.videoList = videoList
        
        return bannerViewController
    }
    
    private func viewController<T:UIViewController>(storyboardName:StoryboardName,viewControllerId:ViewControllerIdentifier? = nil,type:T.Type) -> T {
        if let viewControllerId = viewControllerId {
           return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(viewControllerId.rawValue) as! T
        }
        
        return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateInitialViewController() as! T
    }
    
}