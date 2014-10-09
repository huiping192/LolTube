//
//  RSAppDelegate.m
//  LolTube
//
//  Created by 郭 輝平 on 8/31/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSChannelService.h"
#import "RSVideoListViewController.h"
#import "RSVideoService.h"

@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self p_savePersetting];
    [self p_configureVideoService];

    return YES;
}

- (void)p_savePersetting {
    [self.window setTintColor:[UIColor colorWithRed:255 / 255.0f green:94 / 255.0f blue:58 / 255.0f alpha:1.0]];

    RSChannelService *channelService = [[RSChannelService alloc] init];
    if (!channelService.channelIds) {
        NSArray *channelIds = @[@"UC2t5bjwHdUX4vM2g8TRDq5g", @"UCKDkGnyeib7mcU7LdD3x0jQ", @"UCvqRdlKsE5Q8mf8YXbdIJLw", @"UCUf53DHwoQw4SvETXZQ2Tmg", @"UCGeHk-_K6Lee4CcVN2SKI2A", @"UCN078UFNwPgwWlU_V5WCTNw", @"UC_ZIX-h-BIZZnim6YJSjYDA", @"UCRFvOeB8L5bXeIUVFlHuItA", @"UCa7ycmkvToNPa1hpmLfvkyA", @"UCGgbmTgF-sUJGd5B5N6VSFw", @"UClh5azhOaKzdlThQFgoq-tw", @"UC0RalGf69iYVBFteHInyJJg"];
        [channelService saveChannelIds:channelIds];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *navigationTopViewController = ((UINavigationController *) rootViewController).topViewController;
        if ([navigationTopViewController isKindOfClass:[RSVideoListViewController class]]) {
            [((RSVideoListViewController *) navigationTopViewController) fetchNewDataWithCompletionHandler:completionHandler];
        }
    }
}

- (void)p_configureVideoService {
    RSVideoService *videoService = [RSVideoService sharedInstance];
    [videoService configure];
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
    RSVideoService *videoService = [RSVideoService sharedInstance];
    [videoService save];
}

@end
