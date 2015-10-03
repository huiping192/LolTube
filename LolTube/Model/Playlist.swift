import Foundation

struct Playlist {
    var playlistId: String!
    
    var title: String?
    var channelTitle: String?
    var thumbnailUrl: String?
    var itemCount: Int?

    var videoCountString:String? {
        return (itemCount ?? 0).toVideoCountFormat()
    }
    
    init(_ playlistItem:RSPlaylistItem){
        self.playlistId = playlistItem.playlistId
        self.title = playlistItem.snippet.title
        self.itemCount = Int(playlistItem.contentDetails.itemCount)
        self.thumbnailUrl = playlistItem.snippet.thumbnails.medium.url
    }
    
    init(_ item:RSItem){
        self.playlistId = item.id.playlistId
        self.title = item.snippet.title
        self.thumbnailUrl = item.snippet.thumbnails.medium.url
        self.channelTitle = item.snippet.channelTitle
    }
    
}