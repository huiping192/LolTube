//
//  Channel.swift
//  LolTube
//
//  Created by 郭 輝平 on 9/28/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

enum ThumbnailType {
    case Local
    case Remote
}

protocol Channel {
    
    
    var id: String{
        get
    }
    var title: String?{
        get
    }
    var thumbnailUrl: String?{
        get
    }
    
    var thumbnailType:ThumbnailType{
        get
    }
    
    var selectable: Bool{
        get
    }
    
    var selectedAction:((sourceViewController:UIViewController) -> Void)? {
        get
    }
}


