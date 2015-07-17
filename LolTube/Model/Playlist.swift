import Foundation

struct Playlist {
    var playlistId: String!
    
    var title: String?
    var thumbnailUrl: String?
    var itemCount: Int?

    var videoCountString:String? {
        return (itemCount ?? 0).toVideoCountFormat()
    }
    
    init(playlistItem:RSPlaylistItem){
        self.playlistId = playlistItem.playlistId
        self.title = playlistItem.snippet.title
        self.itemCount = Int(playlistItem.contentDetails.itemCount)
        self.thumbnailUrl = playlistItem.snippet.thumbnails.medium.url
    }
    
}