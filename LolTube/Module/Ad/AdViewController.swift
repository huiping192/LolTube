//
// Created by 郭 輝平 on 3/3/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation
import UIKit
import iAd
import GoogleMobileAds

class AdViewController:UIViewController,ADBannerViewDelegate {
    
    @IBOutlet var adMobBannerView:GADBannerView!
    
    override  func viewDidLoad(){

    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!){
        banner.hidden = true
        self.adMobBannerView.adUnitID = kADMobId
        self.adMobBannerView.rootViewController = self
        self.adMobBannerView.loadRequest(GADRequest())
        
    }

}
