import Foundation


class PlaylistsViewModel:SimpleListCollectionViewModelProtocol {
    let channelId:String
    
    var playlists = [Playlist]()
    private var nextPageToken: String?
    private var totalResults:Int?

    private let youtubeService = YoutubeService()
    
    init(channelId:String){
        self.channelId = channelId
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)){
        guard playlists.count !=  totalResults else {
            success()
            return
        }
        
        let successBlock:((RSPlaylistModel) -> Void) = {
            [unowned self](playlistModel) in
            
            var playlists = [Playlist]()
            
            for playlistItem in playlistModel.items as! [RSPlaylistItem] {
                playlists.append(Playlist(playlistItem:playlistItem))
            }
            
            self.totalResults = Int(playlistModel.pageInfo.totalResults)
            self.nextPageToken = playlistModel.nextPageToken
            self.playlists += playlists
            success()
        }
        
        youtubeService.playlists(channelId,nextPageToken:nextPageToken, success: successBlock, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return playlists.count
    }
}