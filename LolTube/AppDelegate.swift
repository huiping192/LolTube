//
//  AppDelegate.swift
//  LolTube
//
//  Created by 郭 輝平 on 10/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

import Foundation
import AVFoundation
import Fabric
import Crashlytics
import Siren

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate let sharedUserDefaultsSuitName = "kSharedUserDefaultsSuitName"
    fileprivate let channelIdsKey = "channleIds"
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        savePersetting()
        configureVideoService()
        configureCloud()
        configureAnalytics()
        configureSiren()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        return true
    }
    
    fileprivate func configureCloud() {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.storeDidChanged(_:)), name:NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    

    fileprivate func savePersetting() {
        window?.tintColor = UIColor(red: 1.0, green: 94.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
    }

    fileprivate func configureAnalytics() {
        #if DEBUG
        print("No tracking user event in debug model")
        #else
        Fabric.with([Crashlytics.self])
        GGLContext.sharedInstance().configureWithError(nil)
        GAI.sharedInstance().trackUncaughtExceptions = false
        #endif
    }
    
    fileprivate func configureVideoService() {
        let videoService = VideoService.sharedInstance
        videoService.configure()
    }
    
    fileprivate func configureSiren() {
        Siren.shared.wail()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        EventTracker.trackBackgroundFetch()
        guard let rootViewController = window?.rootViewController else {
            completionHandler(.failed)
            return
        }
        rootViewController.fetchNewData(completionHandler)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        guard let videoId = url.host else {
            return false
        }
        
        let videoDetailViewController = ViewControllerFactory.instantiateVideoDetailViewController(videoId)
        currentNavigationController()?.show(videoDetailViewController, sender: self)
        
        return true
    }

    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == kUserActivityTypeVideoDetail && (userActivity.userInfo?[kHandOffVersionKey] as? String) == kHandOffVersion else {
            return false
        }
        
        guard let videoId = userActivity.userInfo?[kUserActivityVideoDetailUserInfoKeyVideoId] as? String else {
            return false
        }
        
        let videoDetailViewController = ViewControllerFactory.instantiateVideoDetailViewController(videoId)
        if let initialPlaybackTime = (userActivity.userInfo?[kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime] as? NSNumber)?.doubleValue {
            videoDetailViewController.initialPlaybackTime = initialPlaybackTime
        }
        currentNavigationController()?.show(videoDetailViewController, sender: self)
        
        return true
    }

    
    fileprivate func currentNavigationController() -> UINavigationController? {
        let rootViewController = window?.rootViewController
        guard let navigationController = ((rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController) else {
            return nil
        }
        
        return navigationController
    }

    @objc func storeDidChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo , let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return 
        }
        
        
        guard reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange else {
            return
        }
        
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }
        
        let store = NSUbiquitousKeyValueStore.default
        keys.forEach{
            if $0 == kPlayFinishedVideoIdsKey {
                VideoService.sharedInstance.overrideVideoDataWithVideoDictionary(store.dictionary(forKey: $0) as? [String : TimeInterval])
            } else if $0 == channelIdsKey {
                let userDefaults = UserDefaults(suiteName: sharedUserDefaultsSuitName)
                userDefaults?.set(store.object(forKey: $0), forKey: $0)
                userDefaults?.synchronize()
            }
        }
            
    }

}
