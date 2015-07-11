import Foundation


class PlaylistsViewModel:SimpleListCollectionViewModelProtocol {
    let channelId:String
    
    var playlists = [Playlist]()
    var nextPageToken: String?
    var totalResults:Int?

    private let youtubeService = YoutubeService()
    
    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        guard playlists.count !=  totalResults else {
            success()
            return
        }
        
        youtubeService.playlists(channelId,nextPageToken:nextPageToken, success: {
            [unowned self](playlistModel) in
            
            var playlists = [Playlist]()
            
            for playlistItem in playlistModel.items as! [RSPlaylistItem] {
                playlists.append(self.convertPlaylist(playlistItem))
            }
            
            self.totalResults = Int(playlistModel.pageInfo.totalResults)
            self.nextPageToken = playlistModel.nextPageToken
            self.playlists += playlists
            success()
            
            }, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return playlists.count
    }
    
    private func convertPlaylist(item: RSPlaylistItem) -> Playlist {
        let playlist = Playlist()
        
        playlist.playlistId = item.playlistId
        playlist.title = item.snippet.title
        playlist.videoCountString = ChannelInfoUtil.convertVideoCount(Int(item.contentDetails.itemCount) ?? 0)
        playlist.thumbnailUrl = item.snippet.thumbnails.medium.url
        
        return playlist
    }
    
    
}