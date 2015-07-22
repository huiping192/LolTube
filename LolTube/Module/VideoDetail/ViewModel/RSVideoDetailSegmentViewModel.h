#import <Foundation/Foundation.h>


@interface RSVideoDetailSegmentViewModel : NSObject

@property(nonatomic, copy) NSString *channelId;
@property(nonatomic, assign) BOOL isSubscribed;

@property(nonatomic, copy) NSString *channelThumbnailImageUrl;
@property(nonatomic, copy) NSString *subscriberCount;

- (instancetype)initWithChannelId:(NSString *)channelId;

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)subscribeChannelWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

@end
