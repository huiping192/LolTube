import Foundation


extension UIViewController {
    
    func instantiateChannelDetailViewController(channelId:String) -> ChannelDetailViewController{
        let channelDetailStoryboard = UIStoryboard(name: "ChannelDetail", bundle: nil)
        let channelDetailViewController = channelDetailStoryboard.instantiateInitialViewController() as! ChannelDetailViewController
        channelDetailViewController.channelId = channelId
        return channelDetailViewController
    }
    
    func instantiateVideoListViewController(channelId:String) -> VideoListViewController{
        let videoListViewController = UIStoryboard(name: "VideoList", bundle: nil).instantiateInitialViewController() as! VideoListViewController
        videoListViewController.channelId = channelId
        return videoListViewController
    }
    
    func instantiatePlaylistsViewController(channelId:String) -> PlaylistsViewController{
        let playlistsViewController = UIStoryboard(name: "ChannelDetail", bundle: nil).instantiateViewControllerWithIdentifier("playlists") as! PlaylistsViewController
        playlistsViewController.channelId = channelId
        return playlistsViewController
    }
    
    func instantiateChannelInfoViewController(description:String) -> ChannelInfoViewController{
        let channelInfoViewController = UIStoryboard(name: "ChannelDetail", bundle: nil).instantiateViewControllerWithIdentifier("channelInfo") as! ChannelInfoViewController
        channelInfoViewController.channelDescription = description
        return channelInfoViewController
    }
    
    func instantiateVideoDetailViewController(videoId:String) -> RSVideoDetailViewController{
        let videoDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("videoDetail") as! RSVideoDetailViewController
        videoDetailViewController.videoId = videoId
        return videoDetailViewController
    }
    
    func instantiatePlaylistViewController(playlistId:String,title:String?) ->  PlaylistViewController{
        let playlistViewController = UIStoryboard(name: "ChannelDetail", bundle: nil).instantiateViewControllerWithIdentifier("playlist") as! PlaylistViewController
        playlistViewController.playlistId = playlistId
        playlistViewController.playlistTitle = title
        
        return playlistViewController
    }
}