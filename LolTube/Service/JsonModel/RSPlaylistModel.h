#import <JSONModel/JSONModel.h>
#import "RSJsonModel.h"
#import "RSThumbnails.h"
#import "RSPageInfo.h"

@protocol RSPlaylistItem;
@class RSPlaylistSnippet;
@class RSPlaylistContentDetails;

@interface RSPlaylistModel : RSJsonModel

@property(nonatomic, copy) NSString<Optional> *nextPageToken;
@property(nonatomic, strong) RSPageInfo *pageInfo;

@property(nonatomic, strong) NSArray <RSPlaylistItem> *items;

@end

@interface RSPlaylistItem : JSONModel
@property(nonatomic, copy) NSString *playlistId;
@property(nonatomic, strong) RSPlaylistSnippet *snippet;
@property(nonatomic, strong) RSPlaylistContentDetails *contentDetails;

@end


@interface RSPlaylistContentDetails : JSONModel

@property(nonatomic, copy) NSString *itemCount;

@end

@interface RSPlaylistSnippet : JSONModel

@property(nonatomic, copy) NSString *publishedAt;
@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) RSThumbnails *thumbnails;
@property(nonatomic, copy) NSString *channelTitle;

@end