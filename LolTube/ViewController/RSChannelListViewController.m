//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelListViewController.h"
#import "RSChannelTableViewCell.h"
#import "RSChannelTableViewModel.h"
#import "UIImageView+RSAsyncLoading.h"
#import "UIViewController+RSLoading.h"
#import "AMTumblrHud.h"
#import "RSVideoListViewController.h"

@interface RSChannelListViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) RSChannelTableViewModel *tableViewModel;

@end

@implementation RSChannelListViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableViewModel = [[RSChannelTableViewModel alloc] init];

    [self configureLoadingView];
    [self.loadingView showAnimated:YES];

    __weak typeof(self) weakSelf = self;
    [self.tableViewModel updateWithSuccess:^{
        [weakSelf.loadingView hide];
        [weakSelf.tableView reloadData];
    }                              failure:^(NSError *error) {
        [weakSelf.loadingView hide];
        NSLog(@"error:%@", error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"selectChannel"]) {

        RSVideoListViewController *videoListViewController = (RSVideoListViewController *) segue.destinationViewController;
        RSChannelTableViewCellVo *item = self.tableViewModel.items[(NSUInteger) self.tableView.indexPathForSelectedRow.row];

        videoListViewController.channelId = item.channelId;
        videoListViewController.channelTitle = item.title;
    }
}


- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonTapped:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.tableViewModel.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];

    RSChannelTableViewCellVo *item = self.tableViewModel.items[(NSUInteger) indexPath.row];
    cell.titleLabel.text = item.title;
    [cell.thumbnailImageView asynLoadingImageWithUrlString:item.mediumThumbnailUrl];

    if ([item.channelId isEqualToString:self.currentChannelId]) {
        cell.titleLabel.textColor = [self.view tintColor];

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.titleLabel.textColor = [UIColor blackColor];

        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //TODO: delete selected data
        //[self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    //TODO: change data sort
}
@end