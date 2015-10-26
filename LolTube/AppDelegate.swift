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
    
    private let sharedUserDefaultsSuitName = "kSharedUserDefaultsSuitName"
    private let channelIdsKey = "channleIds"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        savePersetting()
        configureVideoService()
        configureCloud()
        configureAnalytics()
        configureSiren()
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        return true
    }
    
    private func configureCloud() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "storeDidChanged:", name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: NSUbiquitousKeyValueStore.defaultStore())
        
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    

    private func savePersetting() {
        window?.tintColor = UIColor(red: 1.0, green: 94.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
    }

    private func configureAnalytics() {
        #if DEBUG
        print("No tracking user event in debug model")
        #else
        Fabric.with([Crashlytics.self])
        GGLContext.sharedInstance().configureWithError(nil)
        GAI.sharedInstance().trackUncaughtExceptions = false
        #endif
    }
    
    private func configureVideoService() {
        let videoService = RSVideoService.sharedInstance()
        videoService.configure()
    }
    
    private func configureSiren() {
        let siren = Siren.sharedInstance
        
        siren.appID = "917967826"
        siren.alertType = .Option

        siren.checkVersion(.Daily)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        Siren.sharedInstance.checkVersion(.Weekly)
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        EventTracker.trackBackgroundFetch()
        guard let rootViewController = window?.rootViewController else {
            completionHandler(.Failed)
            return
        }
        rootViewController.fetchNewData(completionHandler)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        guard let videoId = url.host else {
            return false
        }
        
        let videoDetailViewController = ViewControllerFactory.instantiateVideoDetailViewController(videoId)
        currentNavigationController()?.showViewController(videoDetailViewController, sender: self)
        
        return true
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
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
        currentNavigationController()?.showViewController(videoDetailViewController, sender: self)
        
        return true
    }

    
    private func currentNavigationController() -> UINavigationController? {
        let rootViewController = window?.rootViewController
        guard let navigationController = ((rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController) else {
            return nil
        }
        
        return navigationController
    }

    func storeDidChanged(notification: NSNotification) {
        guard let userInfo = notification.userInfo , reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return 
        }
        
        
        guard reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange else {
            return
        }
        
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }
        
        let store = NSUbiquitousKeyValueStore.defaultStore()
        keys.forEach{
            if $0 == kPlayFinishedVideoIdsKey {
                RSVideoService.sharedInstance().overrideVideoDataWithVideoDictionary(store.dictionaryForKey($0))
            } else if $0 == channelIdsKey {
                let userDefaults = NSUserDefaults(suiteName: sharedUserDefaultsSuitName)
                userDefaults?.setObject(store.objectForKey($0), forKey: $0)
                userDefaults?.synchronize()
            }
        }
            
    }

}
