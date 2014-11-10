//
// Created by 郭 輝平 on 11/10/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIViewController+RSError.h"
#import "TSMessage.h"


@implementation UIViewController (RSError)
- (void)showError:(NSError *)error {
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:error.domain
                                       subtitle:error.localizedDescription
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:1.5
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

@end