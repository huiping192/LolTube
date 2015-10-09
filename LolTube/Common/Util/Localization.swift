//
//  LocalizedString.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/3/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

enum Localization:String {
    
    // video quality
    case SwitchVideoQuality
    case VideoQualityHigh
    case VideoQualityMedium
    case VideoQualityLow
    case Cancel
    
    case SuggestionVideos
    
    var localizedString: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}