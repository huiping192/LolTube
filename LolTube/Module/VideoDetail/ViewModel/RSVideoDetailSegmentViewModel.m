#import "RSVideoDetailSegmentViewModel.h"
#import "LolTube-Swift.h"
#import "RSChannelModel.h"
#import "RSThumbnails.h"


@interface RSVideoDetailSegmentViewModel ()

@property(nonatomic, strong) ChannelService *channelService;
@property(nonatomic, strong) YoutubeService *youtubeService;


@end

@implementation RSVideoDetailSegmentViewModel {

}

- (instancetype)initWithChannelId:(NSString *)channelId{
    self = [super init];
    if (self) {
        self.channelId = channelId;
        self.channelService = [[ChannelService alloc] init];
        self.youtubeService = [[YoutubeService alloc] init];
    }

    return self;
}

- (void)updateWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    __weak typeof(self) weakSelf = self;
    [self.youtubeService channelDetail:@[self.channelId] success:^(RSChannelModel *channelModel) {

        if (channelModel.items.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
            return;
        }
        
        RSChannelItem *channelItem = channelModel.items[0];
        weakSelf.channelThumbnailImageUrl =  channelItem.snippet.thumbnails.medium.url;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *subscriberCount = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[channelItem.statistics.subscriberCount integerValue]]];
        weakSelf.subscriberCount = [NSString stringWithFormat:NSLocalizedString(@"ChannelSubscriberCountFormat", nil), subscriberCount];
        weakSelf.isSubscribed = [weakSelf.channelService.channelIds  containsObject:self.channelId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
    }                      failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)subscribeChannelWithSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
     if(self.isSubscribed){
         [self.channelService deleteChannelId:self.channelId];
         self.isSubscribed = NO;
     }  else {
         [self.channelService saveChannelId:self.channelId];
         self.isSubscribed = YES;
     }
    success();
}


@end
