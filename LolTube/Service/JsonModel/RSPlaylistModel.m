#import "RSPlaylistModel.h"

@implementation RSPlaylistModel

@end

@implementation RSPlaylistItem
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id" : @"playlistId"
                                                       }];
}
@end

@implementation RSPlaylistContentDetails

@end
@implementation RSPlaylistSnippet

@end