import Foundation

class SearchPlaylistsViewModel: SimpleListCollectionViewModelProtocol {
    var searchText:String?{
        didSet{
            playlists = [Playlist]()
            playlistsNextPageToken = nil
            playlistsTotalResults = nil
        }
    }
    var playlists = [Playlist]()
    
    private var playlistsNextPageToken: String?
    private var playlistsTotalResults:Int?
    
    private let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success success: (() -> Void), failure: ((error:NSError) -> Void)) {
        guard let searchText = searchText else {
            success()
            return
        }
        
        guard playlistsTotalResults != playlists.count else {
            success()
            return
        }
        
        let successBlock:((RSSearchModel) -> Void) = {
            [unowned self](searchModel) in
            
            var playlists = [Playlist]()
            for item in searchModel.items as! [RSItem] {
                let video = Playlist(item:item)
                playlists.append(video)
            }
            
            let successBlock:(([Playlist]) -> Void) = {
                [unowned self]playlists in
                
                self.playlistsNextPageToken = searchModel.nextPageToken
                self.playlistsTotalResults = Int(searchModel.pageInfo.totalResults)
                self.playlists += playlists
                success()
            }
            
            self.updatePlaylistsDetail(playlists, success: successBlock, failure: failure)
        }
        
        youtubeService.search(.Playlist, searchText: searchText, nextPageToken: playlistsNextPageToken, success: successBlock, failure: failure)
    }
    
    func numberOfItems() -> Int{
        return playlists.count
    }
    
    
    private func updatePlaylistsDetail(playlists:[Playlist],success:(([Playlist]) -> Void),failure: ((error:NSError) -> Void)? = nil){
        let playlistIdList = playlists.map{
            playlist in
            return playlist.playlistId
            } as [String]
        
        let successBlock:((RSPlaylistModel) -> Void) = {
            playlistModel in
            var updatedPlaylists = [Playlist]()
            
            for playlistItem in playlistModel.items as! [RSPlaylistItem]{
                updatedPlaylists.append(Playlist(playlistItem: playlistItem))
            }
            
            success(updatedPlaylists)
        }
        
        youtubeService.playlistsDetail(playlistIdList, success: successBlock, failure: failure)
    }
}
