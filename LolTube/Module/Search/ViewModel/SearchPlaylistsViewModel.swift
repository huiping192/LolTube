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
    
    fileprivate var playlistsNextPageToken: String?
    fileprivate var playlistsTotalResults:Int?
    
    fileprivate let youtubeService = YoutubeService()
    
    init() {
        
    }
    
    func update(success: @escaping (() -> Void), failure: @escaping ((_ error:NSError) -> Void)) {
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
            
            let playlists = (searchModel.items).map{ Playlist($0) }
            
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
    
    fileprivate func updatePlaylistsDetail(_ playlists:[Playlist],success:@escaping (([Playlist]) -> Void),failure: ((_ error:NSError) -> Void)? = nil){
        let playlistIdList = playlists.map{ $0.playlistId! } 
        
        let successBlock:((RSPlaylistModel) -> Void) = {
            playlistModel in
            let updatedPlaylists = (playlistModel.items as! [RSPlaylistItem]).map{ Playlist($0) }
            
            success(updatedPlaylists)
        }
        
        youtubeService.playlistsDetail(playlistIdList, success: successBlock, failure: failure)
    }
}
