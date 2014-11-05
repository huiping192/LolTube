//
//  TodayViewController.m
//  VideoWidget
//
//  Created by 郭 輝平 on 10/29/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "TodayViewController.h"
#import "RSTodayVideoTableViewModel.h"
#import "RSChannelService.h"
#import "UIImageView+Loading.h"
#import <NotificationCenter/NotificationCenter.h>

static const NSInteger kMaxCellNumber = 5;
static NSString *const kCellId = @"videoCell";

static const CGFloat kCellHeight = 60.0f;

// scheme
static NSString *const kLolTubeSchemeHost = @"loltube://";
static NSString *const kLolTubeSchemeVideoPath = @"";


@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) RSTodayVideoTableViewModel *tableViewModel;

@end

@implementation TodayViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    RSChannelService *channelService = [[RSChannelService alloc] init];
    self.tableViewModel = [[RSTodayVideoTableViewModel alloc] initWithChannelIds:[channelService channelIds]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //load cache data
    __weak typeof(self) weakSelf = self;
    [self.tableViewModel updateCacheDataWithSuccess:^(BOOL hasCacheData) {
        if (hasCacheData) {
            [weakSelf p_reloadData];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    __weak typeof(self) weakSelf = self;
    [self.tableViewModel updateWithSuccess:^(BOOL hasNewData) {
        [weakSelf p_reloadData];
        completionHandler(hasNewData ? NCUpdateResultNewData : NCUpdateResultNoData);
    }                              failure:^(NSError *error) {
        completionHandler(NCUpdateResultFailed);
    }];
}

- (void)p_reloadData {
    [self.tableView reloadData];
    self.tableView.tableFooterView = [self p_tableViewFootView];
    [self setPreferredContentSize:self.tableView.contentSize];
}

-(UIView *)p_tableViewFootView{
    if (self.tableViewModel.items.count <= kMaxCellNumber) {
        return nil;
    }
    UILabel *moreInformationLabel = [[UILabel alloc] init];
    moreInformationLabel.frame = CGRectMake(18, 0, self.tableView.frame.size.width, kCellHeight);
    moreInformationLabel.textColor = [UIColor whiteColor];
    moreInformationLabel.font = [UIFont systemFontOfSize:16];
    moreInformationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VideoWidgetMoreVideos", @"Check %d more videos on LolTube"), self.tableViewModel.items.count - kMaxCellNumber];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreInformationLabelTapped)];
    [moreInformationLabel addGestureRecognizer:tapGestureRecognizer];
    [moreInformationLabel setUserInteractionEnabled:YES];
    return  moreInformationLabel;
}

-(void)moreInformationLabelTapped{
    [self.extensionContext openURL:[NSURL URLWithString:kLolTubeSchemeHost] completionHandler:nil];
}
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewModel.items.count > kMaxCellNumber ? kMaxCellNumber : self.tableViewModel.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    RSVideoListTableViewCellVo *cellVo = (RSVideoListTableViewCellVo *) self.tableViewModel.items[(NSUInteger) indexPath.row];

    [cell.imageView asynLoadingImageWithUrlString:cellVo.defaultThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];
    cell.textLabel.text = cellVo.title;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    RSVideoListTableViewCellVo *cellVo = (RSVideoListTableViewCellVo *) self.tableViewModel.items[(NSUInteger) indexPath.row];

    NSString *urlString = cellVo.videoId ? [NSString stringWithFormat:@"%@%@%@", kLolTubeSchemeHost, kLolTubeSchemeVideoPath, cellVo.videoId] : kLolTubeSchemeHost;
    [self.extensionContext openURL:[NSURL URLWithString:urlString] completionHandler:nil];

}

@end
