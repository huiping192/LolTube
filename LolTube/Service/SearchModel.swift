//
//  SearchModel.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/12/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import Parse

class SearchModel: PFObject,PFSubclassing {
    
    let text: String
    let localization: String
    
    init(text: String, localization: String) {
        self.text = text
        self.localization = localization
        
        super.init()
    }
    
    static func parseClassName() -> String {
        return "Search"
    }
}