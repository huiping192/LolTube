//
//  RSStreamListModel.h
//  LolTube
//
//  Created by 郭 輝平 on 9/16/15.
//  Copyright © 2015 Huiping Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"

@protocol RSStreamModel;
@class RSTwitchChannelModel;
@class RSPreviewModel;
@class RSStreamModel;

@interface RSStreamListModel : RSJsonModel

@property(nonatomic, copy) NSNumber *_total;
@property(nonatomic, strong) NSArray<RSStreamModel *><RSStreamModel> *streams;

@end


@interface RSStreamModel : JSONModel

@property(nonatomic, copy) NSNumber *viewers;
@property(nonatomic, copy) NSNumber *_id;
@property(nonatomic, copy) RSTwitchChannelModel *channel;
@property(nonatomic, copy) RSPreviewModel *preview;

@end


@interface RSTwitchChannelModel : JSONModel

@property(nonatomic, copy) NSString *display_name;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSNumber *_id;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSNumber *followers;
@property(nonatomic, copy) NSNumber *views;
@property(nonatomic, copy) NSString<Optional> *logo;

@end


@interface RSPreviewModel : JSONModel

@property(nonatomic, copy) NSString *medium;

@end




