//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelListViewController.h"
#import "RSChannelTableViewCell.h"
#import "RSChannelTableViewModel.h"
#import "UIViewController+RSLoading.h"
#import "RSVideoListViewController.h"
#import "RSSearchTableViewCell.h"
#import "RSChannelService.h"
#import "UIImageView+Loading.h"
#import "UIViewController+RSError.h"
#import "RSEventTracker.h"
#import "LolTube-Swift.h"

@interface RSChannelListViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) RSChannelTableViewModel *tableViewModel;
@end

@implementation RSChannelListViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];

    self.tableViewModel = [[RSChannelTableViewModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self p_loadData];
}


- (void)p_loadData {
    self.tableView.alpha = 0;
    [self animateLoadingView];

    __weak typeof(self) weakSelf = self;
    [self.tableViewModel updateWithSuccess:^{
        [weakSelf stopAnimateLoadingView];
        [weakSelf.tableView reloadData];
        NSIndexPath *currentSelectedIndexPath = [self p_currentSelectedIndexPath];
        if (currentSelectedIndexPath) {
            [self.tableView scrollToRowAtIndexPath:currentSelectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.tableView.alpha = 1.0;
            }                completion:^(BOOL finished) {
                [self.tableView flashScrollIndicators];
            }];
        });
    }                              failure:^(NSError *error) {
        [self showError:error];
        [weakSelf stopAnimateLoadingView];
    }];
}

- (NSIndexPath *)p_currentSelectedIndexPath {
    if (self.currentChannelIds.count > 1) { // all channel
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if (self.currentChannelIds.count == 1) {
        for (RSChannelTableViewCellVo *item in self.tableViewModel.items) {
            if ([item.channelId isEqualToString:self.currentChannelIds[0]]) {
                return [NSIndexPath indexPathForRow:[self.tableViewModel.items indexOfObject:item] inSection:0];
            }
        }
    }
    return nil;
}

- (void)preferredContentSizeChanged:(id)preferredContentSizeChanged {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"showChannel"]) {
        RSChannelTableViewCellVo *item = self.tableViewModel.items[(NSUInteger) self.tableView.indexPathForSelectedRow.row];

        if ([item.channelId isEqualToString:@"All Channels"]) {
            RSVideoListViewController *videoListViewController = (RSVideoListViewController *) segue.destinationViewController;

            RSChannelService *channelService = [[RSChannelService alloc] init];
            videoListViewController.channelIds = channelService.channelIds;
            videoListViewController.navigationTitle = @"LolTube";
            videoListViewController.needShowChannelTitleView = YES;
        } else {
            RSVideoListViewController *videoListViewController = (RSVideoListViewController *) segue.destinationViewController;

            videoListViewController.channelIds = @[item.channelId];
            videoListViewController.navigationTitle = item.title;
            videoListViewController.needShowChannelTitleView = NO;
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonTapped:(id)sender {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.isEditing ? UIBarButtonSystemItemEdit : UIBarButtonSystemItemCancel target:self action:@selector(editButtonTapped:)];
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.tableViewModel.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.tableViewModel.items.count) {
        RSSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        cell.searchImageView.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.searchLabel.text = NSLocalizedString(@"SearchChannels", @"Explore More Channels");
        cell.searchLabel.textColor = self.view.tintColor;
        cell.searchLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

        return cell;
    }

    RSChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];

    RSChannelTableViewCellVo *item = self.tableViewModel.items[(NSUInteger) indexPath.row];
    cell.titleLabel.text = item.title;
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [cell.thumbnailImageView asynLoadingImageWithUrlString:item.mediumThumbnailUrl placeHolderImage:[UIImage imageNamed:@"DefaultThumbnail"]];

    if (self.currentChannelIds.count > 1 && [item.channelId isEqualToString:@"All Channels"]) { // all channel
        cell.titleLabel.textColor = [self.view tintColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (self.currentChannelIds.count == 1 && [item.channelId isEqualToString:self.currentChannelIds[0]]) {
        cell.titleLabel.textColor = [self.view tintColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0 && indexPath.row != self.tableViewModel.items.count;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0 && indexPath.row != self.tableViewModel.items.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RSChannelTableViewCellVo *cellVo = self.tableViewModel.items[(NSUInteger) indexPath.row];
        [self.tableViewModel deleteChannelWithIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [RSEventTracker trackChannelListDeleteWithChannelId:cellVo.channelId];
    }
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.tableViewModel moveChannelWithIndexPath:sourceIndexPath toIndexPath:toIndexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *channelDetailStoryboard = [UIStoryboard storyboardWithName:@"ChannelDetail" bundle:nil];
    ChannelDetailViewController *channelDetailViewController = [channelDetailStoryboard instantiateInitialViewController];
    RSChannelTableViewCellVo *cellVo = self.tableViewModel.items[(NSUInteger) indexPath.row];
    channelDetailViewController.channelId = cellVo.channelId;
    [self.navigationController pushViewController:channelDetailViewController animated:YES];
}

@end