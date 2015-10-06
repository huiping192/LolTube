

import Foundation

class TwitchStream: TopItem {
    var id: String {
        return "Twitch Stream  \(streamId)"
    }
    var streamId: String!
    var displayName: String!
    var name: String!
    var title: String?
    var thumbnailUrl: String?
    var highThumbnailUrl: String?
    var viewers: Int?
    var followers: Int?
    var views: Int?
    var logo: String?

    var subTitle: String?{
        return viewersString
    }
    
    var viewersString: String?{
        return viewers?.toViewerCountFormat()
    }

    var viewCountString: String? {
        return RSVideoInfoUtil.convertVideoViewCount(views ?? 0)
    }
    
    var followersString: String? {
        return RSVideoInfoUtil.convertFollowerCount(followers ?? 0)
    }
    
    var selectedAction:(sourceViewController:UIViewController) -> Void {
        return { [weak self]sourceViewController in
            guard let strongSelf = self else {
                return 
            }
            sourceViewController.showViewController(ViewControllerFactory.instantiateTwitchStreamViewController(strongSelf), sender: sourceViewController)
        }
    }
    init(_ streamModel:RSStreamModel){
        self.streamId = String(streamModel._id)
        self.title = streamModel.channel.status
        self.displayName = streamModel.channel.display_name
        self.name = streamModel.channel.name
        self.highThumbnailUrl = streamModel.preview.medium
        self.thumbnailUrl = streamModel.preview.medium
        self.viewers = Int(streamModel.viewers)
        self.followers = Int(streamModel.channel.followers)
        self.views = Int(streamModel.channel.views)
        self.logo = streamModel.channel.logo
    }
}