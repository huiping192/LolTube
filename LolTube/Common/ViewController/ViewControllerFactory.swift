import Foundation

struct ViewControllerFactory {
    fileprivate enum StoryboardName:String {
        case ChannelDetail = "ChannelDetail"
        case VideoList = "VideoList"
        case Search = "Search"
        case Main = "Main"
        case Banner = "Banner"
        case Twitch
        
    }
    
    fileprivate enum ViewControllerIdentifier:String {
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
        
        // twitch
        case Stream
        
    }
    
    static func instantiateChannelDetailViewController(id:String,title:String?) -> ChannelDetailViewController{
        let channelDetailViewController = viewController(.ChannelDetail, type: ChannelDetailViewController.self)
        channelDetailViewController.channelId = id
        channelDetailViewController.channelTitle = title
        
        return channelDetailViewController
    }
    
    static func instantiateVideoListViewController(_ channelId:String,channelTitle:String) -> VideoListViewController{
        let videoListViewController = viewController(.VideoList, type: VideoListViewController.self)
        videoListViewController.channelId = channelId
        videoListViewController.channelTitle = channelTitle
        return videoListViewController
    }
    
    static func instantiatePlaylistsViewController(_ channelId:String,channelTitle:String) -> PlaylistsViewController{
        let playlistsViewController = viewController(.ChannelDetail,viewControllerId:.playlists, type: PlaylistsViewController.self)
        
        playlistsViewController.channelId = channelId
        playlistsViewController.channelTitle = channelTitle
        
        return playlistsViewController
    }
    
    static func instantiateChannelInfoViewController(_ description:String,channelId:String,channelTitle:String) -> ChannelInfoViewController{
        
        let channelInfoViewController = viewController(.ChannelDetail,viewControllerId:.channelInfo, type: ChannelInfoViewController.self)
        
        channelInfoViewController.channelTitle = channelTitle
        channelInfoViewController.channelId = channelId
        channelInfoViewController.channelDescription = description
        
        return channelInfoViewController
    }
    
    static func instantiateVideoDetailViewController(_ videoId:String) -> VideoDetailViewController{
        let videoDetailViewController = viewController(.Main,viewControllerId:.videoDetail, type: VideoDetailViewController.self)
        
        videoDetailViewController.videoId = videoId
        return videoDetailViewController
    }
    
    static func instantiatePlaylistViewController(_ playlistId:String,title:String?) ->  PlaylistViewController{
        let playlistViewController = viewController(.ChannelDetail,viewControllerId:.playlist, type: PlaylistViewController.self)
        
        playlistViewController.playlistId = playlistId
        playlistViewController.playlistTitle = title
        
        return playlistViewController
    }
    
    static func instantiateSearchVideoListViewController(_ searchText:String) ->  SearchVideoListViewController{
        let searchVideoListViewController = viewController(.Search,viewControllerId:.SearchVideoList, type: SearchVideoListViewController.self)
        
        searchVideoListViewController.searchText = searchText
        
        return searchVideoListViewController
    }
    
    static func instantiateSearchChannelListViewController(_ searchText:String) ->  SearchChannelListViewController{
        let searchChannelListViewController = viewController(.Search,viewControllerId:.SearchChannelList, type: SearchChannelListViewController.self)
        
        searchChannelListViewController.searchText = searchText
        
        return searchChannelListViewController
    }
    
    static func instantiateSearchPlaylistsViewController(_ searchText:String) ->  SearchPlaylistsViewController{
        let searchPlaylistsViewController = viewController(.Search,viewControllerId:.SearchPlaylists, type: SearchPlaylistsViewController.self)
        
        searchPlaylistsViewController.searchText = searchText
        
        return searchPlaylistsViewController
    }
    
    static func instantiateBannerViewController(_ bannerItemList:[TopItem]) ->  BannerViewController{
        let bannerViewController = viewController(.Banner, type: BannerViewController.self)
        
        bannerViewController.bannerItemList = bannerItemList
        
        return bannerViewController
    }
    
    static func instantiateSplitBannerViewController(_ bannerItemList:[TopItem]) ->  SplitBannerViewController{
        let bannerViewController = viewController(.Banner,viewControllerId:.SplitBanner, type: SplitBannerViewController.self)
        
        bannerViewController.bannerItemList = bannerItemList
        
        return bannerViewController
    }
    
    static func instantiateCombinedBannerViewController(_ bannerItemList:[TopItem]) ->  CombinedBannerViewController{
        let bannerViewController = viewController(.Banner,viewControllerId:.CombinedBanner, type: CombinedBannerViewController.self)
        
        bannerViewController.bannerItemList = bannerItemList
        
        return bannerViewController
    }
    
    static func instantiateTwitchStreamViewController(_ steam :TwitchStream) ->  TwitchStreamViewController{
        let twitchStreamViewController = viewController(.Twitch,viewControllerId:.Stream, type: TwitchStreamViewController.self)
        twitchStreamViewController.stream = steam
        return twitchStreamViewController
    }
    
    static func instantiateTwitchStreamListViewController() -> TwitchStreamListViewController{
        let twitchStreamListViewController = viewController(.Twitch, type: TwitchStreamListViewController.self)
        return twitchStreamListViewController
    }
    
    static fileprivate func viewController<T:UIViewController>(_ storyboardName:StoryboardName,viewControllerId:ViewControllerIdentifier? = nil,type:T.Type) -> T {
        if let viewControllerId = viewControllerId {
            return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateViewController(withIdentifier: viewControllerId.rawValue) as! T
        }
        
        return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateInitialViewController() as! T
    }
    
}
