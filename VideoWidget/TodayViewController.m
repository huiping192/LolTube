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

- (void)viewDidLoad {
    [super viewDidLoad];
    RSChannelService *channelService = [[RSChannelService alloc] init];
    self.tableViewModel = [[RSTodayVideoTableViewModel alloc] initWithChannelIds:[channelService channelIds]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableViewModel updateWithSuccess:^{
        [self.tableView reloadData];
        [self setPreferredContentSize:self.tableView.contentSize];
    }                              failure:^(NSError *error) {
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

    [self.tableViewModel updateWithSuccess:^{
        [self.tableView reloadData];
        [self setPreferredContentSize:self.tableView.contentSize];
        completionHandler(NCUpdateResultNewData);
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
    if(cellVo.videoId){
        [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"loltube://%@", cellVo.videoId]] completionHandler:nil];
    } else{
        [self.extensionContext openURL:[NSURL URLWithString:@"loltube://"] completionHandler:nil];
    }
}

@end
