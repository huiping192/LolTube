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
            [weak self](playlistModel) in
            
            let playlists = (playlistModel.items as! [RSPlaylistItem]).map{ Playlist($0) }
            
            self?.totalResults = Int(playlistModel.pageInfo.totalResults)
            self?.nextPageToken = playlistModel.nextPageToken
            self?.playlists += playlists
            success()
        }
        
        youtubeService.playlists(channelId,nextPageToken:nextPageToken, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int {
        return playlists.count
    }
    
    func allNumberOfItems() -> Int {
        return totalResults ?? 0
    }
}