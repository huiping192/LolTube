import Foundation

extension UIViewController {
    private enum StoryboardName:String {
        case ChannelDetail = "ChannelDetail"
        case VideoList = "VideoList"
        case Main = "Main"
    }
    
    private enum ViewControllerIdentifier:String {
        case playlist = "playlist"
        case videoDetail = "videoDetail"
        case playlists = "playlists"
        case channelInfo = "channelInfo"
    }
    
    func instantiateChannelDetailViewController(channelId:String) -> ChannelDetailViewController{
        let channelDetailViewController = viewController(.ChannelDetail, type: ChannelDetailViewController.self)
        channelDetailViewController.channelId = channelId
        return channelDetailViewController
    }
    
    func instantiateVideoListViewController(channelId:String) -> VideoListViewController{
        let videoListViewController = viewController(.VideoList, type: VideoListViewController.self)
        videoListViewController.channelId = channelId
        return videoListViewController
    }
    
    func instantiatePlaylistsViewController(channelId:String) -> PlaylistsViewController{
        let playlistsViewController = viewController(.ChannelDetail,viewControllerId:.playlists, type: PlaylistsViewController.self)
        
        playlistsViewController.channelId = channelId
        return playlistsViewController
    }
    
    func instantiateChannelInfoViewController(description:String) -> ChannelInfoViewController{
        
        let channelInfoViewController = viewController(.ChannelDetail,viewControllerId:.channelInfo, type: ChannelInfoViewController.self)
        
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
    
    private func viewController<T:UIViewController>(storyboardName:StoryboardName,viewControllerId:ViewControllerIdentifier? = nil,type:T.Type) -> T {
        if let viewControllerId = viewControllerId {
           return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(viewControllerId.rawValue) as! T
        }
        
        return UIStoryboard(name: storyboardName.rawValue, bundle: nil).instantiateInitialViewController() as! T
    }
}