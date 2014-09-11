//
// Created by 郭 輝平 on 9/12/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "RSChannelListViewController.h"
#import "RSChannelTableViewCell.h"

@interface RSChannelListViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSDictionary *data;
@end

@implementation RSChannelListViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.data = @{@"League of Legends" : @"UC2t5bjwHdUX4vM2g8TRDq5g", @"TVOngamenet" : @"UCKDkGnyeib7mcU7LdD3x0jQ", @"LoL Esports" : @"UCvqRdlKsE5Q8mf8YXbdIJLw"};
}

-(IBAction)closeButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)editButtonTapped:(id)sender{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];

    NSString *key = [self.data allKeys][indexPath.row];
    cell.titleLabel.text = key;


    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end