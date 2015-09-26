

import Foundation

class TwitchStream: BannerItem  {
    var id: String!
    var name: String!
    var title: String?
    var thumbnailUrl: String?
    var highThumbnailUrl: String?
    var viewers: Int?
    var followers: Int?
    var views: Int?
    var logo: String?

    var viewCountString: String? {
        return RSVideoInfoUtil.convertVideoViewCount(views ?? 0)
    }
    
    var viewersString: String? {
        return viewers?.toViewerCountFormat()
    }
    
    var followersString: String? {
        return RSVideoInfoUtil.convertFollowerCount(followers ?? 0)
    }
    
    var selectedAction:(sourceViewController:UIViewController) -> Void {
        return { [weak self]sourceViewController in
            guard let strongSelf = self else {
                return 
            }
            sourceViewController.showViewController(sourceViewController.instantiateTwitchStreamViewController(strongSelf), sender: sourceViewController)
        }
    }
    init(_ streamModel:RSStreamModel){
        self.id = String(streamModel._id)
        self.title = streamModel.channel.status
        self.name = streamModel.channel.display_name
        self.highThumbnailUrl = streamModel.preview.medium
        self.thumbnailUrl = streamModel.preview.medium
        self.viewers = Int(streamModel.viewers)
        self.followers = Int(streamModel.channel.followers)
        self.views = Int(streamModel.channel.views)
        self.logo = streamModel.channel.logo
    }
}