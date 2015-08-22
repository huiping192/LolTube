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
            [weak self](searchModel) in
            
            let playlists = (searchModel.items as! [RSItem]).map{ Playlist(item:$0) }
            
            let successBlock:(([Playlist]) -> Void) = {
                [weak self]playlists in
                
                self?.playlistsNextPageToken = searchModel.nextPageToken
                self?.playlistsTotalResults = Int(searchModel.pageInfo.totalResults)
                self?.playlists += playlists
                success()
            }
            
            self?.updatePlaylistsDetail(playlists, success: successBlock, failure: failure)
        }
        
        youtubeService.search(.Playlist, searchText: searchText, nextPageToken: playlistsNextPageToken, success: successBlock, failure: failure)
    }
    
    func loadedNumberOfItems() -> Int {
        return playlists.count
    }
    
    func allNumberOfItems() -> Int {
        return playlistsTotalResults ?? 0
    }
    
    private func updatePlaylistsDetail(playlists:[Playlist],success:(([Playlist]) -> Void),failure: ((error:NSError) -> Void)? = nil){
        let playlistIdList = playlists.map{ $0.playlistId! } 
        
        let successBlock:((RSPlaylistModel) -> Void) = {
            playlistModel in
            let updatedPlaylists = (playlistModel.items as! [RSPlaylistItem]).map{ Playlist(playlistItem: $0) }
            
            success(updatedPlaylists)
        }
        
        youtubeService.playlistsDetail(playlistIdList, success: successBlock, failure: failure)
    }
}
