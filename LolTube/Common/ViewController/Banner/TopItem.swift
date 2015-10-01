import Foundation

protocol TopItem {
    var id:String{
        get
    }
    
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

