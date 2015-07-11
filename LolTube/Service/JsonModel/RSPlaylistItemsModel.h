#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"
#import "RSSearchModel.h"
#import "RSPageInfo.h"

@protocol RSPlaylistVideoItem;
@class RSPlaylistVideoItemSnippet;
@class RSPlaylistVideoItemResourceId;

@interface RSPlaylistVideoItem : JSONModel

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) RSPlaylistVideoItemSnippet *snippet;

@end


@interface RSPlaylistItemsModel : RSJsonModel

@property(nonatomic, copy) NSString<Optional> *nextPageToken;

@property(nonatomic, strong) RSPageInfo *pageInfo;

@property(nonatomic, strong) NSArray<RSPlaylistVideoItem> *items;

@end

@interface RSPlaylistVideoItemSnippet : JSONModel

@property(nonatomic, copy) NSString *publishedAt;
@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) RSThumbnails<Optional> *thumbnails;
@property(nonatomic, copy) NSString *channelTitle;
@property(nonatomic, strong) RSPlaylistVideoItemResourceId *resourceId;

@end

@interface RSPlaylistVideoItemResourceId : JSONModel
@property(nonatomic, copy) NSString *videoId;

@end