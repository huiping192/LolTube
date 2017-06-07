//
//  UINavigationController.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation

extension UINavigationController {
    override func fetchNewData(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let visibleViewController = visibleViewController else {
            completionHandler(.failed)
            return
        }
        visibleViewController.fetchNewData(completionHandler)
    }
}
