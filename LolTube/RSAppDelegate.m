//
//  RSAppDelegate.m
//  LolTube
//
//  Created by 郭 輝平 on 8/31/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSVideoService.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/Analytics.h>
#import <AVFoundation/AVFoundation.h>
#import "LolTube-Swift.h"
#import "RSEnvironment.h"

static NSString *const kSharedUserDefaultsSuitName = @"kSharedUserDefaultsSuitName";
static NSString *const kChannelIdsKey = @"channleIds";


@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self p_savePersetting];
    [self p_configureVideoService];
    [self p_configureCloud];
    [self p_configureAnalytics];
    
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    return YES;
}

- (void)p_savePersetting {
    [self.window setTintColor:[UIColor colorWithRed:255 / 255.0f green:94 / 255.0f blue:58 / 255.0f alpha:1.0]];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"background fetch started.");
    
    [EventTracker trackBackgroundFetch];
    TopViewController *topViewController = [self p_topViewController];
    if (topViewController){
        [topViewController fetchNewData:completionHandler];
    } else {
        NSLog(@"background fetch failed.");
        completionHandler(UIBackgroundFetchResultFailed); 
    }
}


-(TopViewController *)p_topViewController{
    UINavigationController *navigationViewController = [self p_currentNavigationController];
    UIViewController *navigationTopViewController = navigationViewController.topViewController;
    if ([navigationTopViewController isKindOfClass:[TopViewController class]]) {
        return (TopViewController *)navigationTopViewController;
    }
    
    return nil;
}

- (void)p_configureVideoService {
    RSVideoService *videoService = [RSVideoService sharedInstance];
    [videoService configure];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *videoId = url.host;

    if (videoId) {
        VideoDetailViewController *videoDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoDetail"];
        videoDetailViewController.videoId = videoId;
        
        [[self p_currentNavigationController] showViewController:videoDetailViewController sender:self];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([userActivity.activityType isEqualToString:kUserActivityTypeVideoDetail] && [userActivity.userInfo[kHandOffVersionKey] isEqualToString:kHandOffVersion]) {
        
        VideoDetailViewController *videoDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kViewControllerIdVideoDetail];
        videoDetailViewController.videoId = userActivity.userInfo[kUserActivityVideoDetailUserInfoKeyVideoId];
        videoDetailViewController.initialPlaybackTime = [((NSNumber *) userActivity.userInfo[kUserActivityVideoDetailUserInfoKeyVideoCurrentPlayTime]) floatValue];
        
        [[self p_currentNavigationController] showViewController:videoDetailViewController sender:self];
    }

    return YES;
}

-(UINavigationController *)p_currentNavigationController{
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *) tabBarController.selectedViewController;
        }
    }
    return nil;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)p_configureCloud {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];

    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (void)p_configureAnalytics {
#ifdef DEBUG
    NSLog(@"No tracking user event in debug model");
#else
    [Fabric with:@[CrashlyticsKit]];
    
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;
#endif
    
}

- (void)storeDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey];

    if (reason) {
        NSInteger reasonValue = [reason integerValue];
        if ((reasonValue == NSUbiquitousKeyValueStoreServerChange) || (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange)) {
            NSArray *keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
            NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];

            for (NSString *key in keys) {
                if([key isEqualToString:kPlayFinishedVideoIdsKey]){
                    [[RSVideoService sharedInstance] overrideVideoDataWithVideoDictionary:[store dictionaryForKey:key]];
                } else if([key isEqualToString:kChannelIdsKey]){
                    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kSharedUserDefaultsSuitName];
                    [userDefaults setObject:[store objectForKey:key] forKey:key];
                    [userDefaults synchronize];
                }

            }

        }
    }
}
@end
