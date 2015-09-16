import Foundation

protocol BannerItem {
    var title: String?{
        get
    }
    var thumbnailUrl: String?{
        get
    }
    
    var highThumbnailUrl: String?{
        get
    }

    var selectedAction:(sourceViewController:UIViewController) -> Void {
        get
    }

    
}

