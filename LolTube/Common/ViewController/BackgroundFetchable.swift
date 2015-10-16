//
//  BackgroundFetchable.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

protocol BackgroundFetchable {
     func fetchNewData(completionHandler: (UIBackgroundFetchResult) -> Void)
}