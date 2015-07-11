import Foundation

class Channel: Hashable {
    var channelId: String!
    var title: String?
    var description: String?
    var thumbnailUrl: String?
    var bannerImageUrl: String?

    var videoCount: Int?
    var subscriberCount: Int?
    var viewCount: Int?
    var videoCountString: String?
    var subscriberCountString: String?
    var viewCountString: String?

    init() {

    }

    var hashValue: Int {
        return 1
    }
}

func ==(lhs: Channel, rhs: Channel) -> Bool {
    return lhs.channelId == rhs.channelId
}