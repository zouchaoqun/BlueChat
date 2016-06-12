//
//  AddFriendViewController.m
//  BlueChat
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "AddFriendViewController.h"
#import <BlueChatLib/BlueChatLib.h>

@interface AddFriendViewController () <BCChatServerSearchResultDelegate>

@end

@implementation AddFriendViewController

static NSString *const AddFriendTableViewCellReuseIdentifier = @"AddFriendTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[BCChatClient sharedInstance] searchForChatServerWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[BCChatClient sharedInstance] stopSearchingForChatServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addServer:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [[BCChatServerInfoManager sharedManager] makeServerFriend:indexPath.row];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BCChatServerSearchResultDelegate
- (void)didFindChatServer {
    [self.tableView reloadData];
}

- (void)searchInterrupted {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BCChatServerInfoManager sharedManager] numberOfServers:NO];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendTableViewCellReuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    BCChatServerInfo *info = [[BCChatServerInfoManager sharedManager] serverAtIndex:indexPath.row isFriend:NO];
    if (info) {
        cell.textLabel.text = info.name;
    }
    
    return cell;
}

@end
