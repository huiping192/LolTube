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
            [weakSelf.tableView reloadData];
            [weakSelf setPreferredContentSize:weakSelf.tableView.contentSize];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.

    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    __weak typeof(self) weakSelf = self;
    [self.tableViewModel updateWithSuccess:^(BOOL hasNewData) {
        [weakSelf.tableView reloadData];
        [weakSelf setPreferredContentSize:weakSelf.tableView.contentSize];
        completionHandler(hasNewData ? NCUpdateResultNewData : NCUpdateResultNoData);
    }                              failure:^(NSError *error) {
        completionHandler(NCUpdateResultFailed);
    }];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewModel.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];

    RSVideoListTableViewCellVo *cellVo = (RSVideoListTableViewCellVo *) self.tableViewModel.items[(NSUInteger) indexPath.row];
    [cell.imageView asynLoadingImageWithUrlString:cellVo.defaultThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];

    cell.textLabel.text = cellVo.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    RSVideoListTableViewCellVo *cellVo = (RSVideoListTableViewCellVo *) self.tableViewModel.items[(NSUInteger) indexPath.row];
    if (cellVo.videoId) {
        [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"loltube://%@", cellVo.videoId]] completionHandler:nil];
    } else {
        [self.extensionContext openURL:[NSURL URLWithString:@"loltube://"] completionHandler:nil];
    }
}

@end
