//
//  FriendsViewController.m
//  BlueChat
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "FriendsViewController.h"
#import "ChatViewController.h"
#import <BlueChatLib/BlueChatLib.h>

@interface FriendsViewController () <BCChatServerDelegate, BCChatClientDelegate, UITableViewDataSource>

@property (strong, nonatomic) ChatViewController *chatViewController;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendBarButton;

@end

@implementation FriendsViewController

static NSString *const FriendsTableViewCellReuseIdentifier = @"FriendsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // we need to create the chatViewController now so it can be passed as chatManagerDelegate to BCChatServer
    // otherwise in edge cases the chatRoomDidClose message might be missed
    self.chatViewController = [self createChatViewController];
    
    [[BCChatServer sharedInstance] initChatServerWithName:@"abcdefgh12345678" chatServerDelegate:self chatManagerDelegate:self.chatViewController];
    
    [[BCChatClient sharedInstance] initChatClientWithDelegate:self chatManagerDelegate:self.chatViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.friendsTableView reloadData];

    // BCChatServer will take care of whether it can resume
    [[BCChatServer sharedInstance] resumeChatServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Helpers
- (ChatViewController *)createChatViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
}

- (void)handleServicesReady:(BOOL)ready withMessage:(NSString *)message {
    
    self.errorMessageLabel.text = message;
    self.errorMessageLabel.hidden = ready;
    self.friendsTableView.hidden = !ready;
    self.addFriendBarButton.enabled = ready;
    
    [self.friendsTableView reloadData];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Message", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)chatDidBeginWithChatManager:(id<BCChatManagerInterface>)chatManager {
    [[BCChatServer sharedInstance] pauseChatServier];
    
    self.chatViewController.chatManager = chatManager;
    [self.navigationController pushViewController:self.chatViewController animated:YES];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BCChatServerInfoManager sharedManager] numberOfServers:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendsTableViewCellReuseIdentifier];

    BCChatServerInfo *info = [[BCChatServerInfoManager sharedManager] serverAtIndex:indexPath.row isFriend:YES];
    if (info) {
        cell.textLabel.text = info.name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BCChatServerInfo *info = [[BCChatServerInfoManager sharedManager] serverAtIndex:indexPath.row isFriend:YES];
    if (info) {
        [[BCChatClient sharedInstance] connectToChatServer:info];
    }
    else {
        [self showAlertMessage:NSLocalizedString(@"Could not connect to server. Please try again later.", @"")];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BCChatServerDelegate
- (void)chatServerDidStart {
    
    NSLog(@"chat server started");
    if ([BCChatClient sharedInstance].isChatClientReady) {
        [self handleServicesReady:YES withMessage:@""];
    }
}

- (void)chatServerDidFail:(NSString *)errorMessage {
  
    NSLog(@"chat server failed %@", errorMessage);
    [self handleServicesReady:NO withMessage:errorMessage];
}

- (void)chatClientDidCome {
    
    if (self.navigationController.topViewController == self.chatViewController) {
        NSLog(@"already chatting");
        return;
    }
    
    [self chatDidBeginWithChatManager:[BCChatServer sharedInstance]];
}


#pragma mark - BCChatClientDelegate
- (void)chatClientDidBecomeReady {
    
    NSLog(@"chat cleint ready");
    if ([BCChatServer sharedInstance].isChatServerReady) {
        [self handleServicesReady:YES withMessage:@""];
    }
}

- (void)chatClientDidBecomeUnready:(NSString *)errorMessage {
    
    NSLog(@"chat client unready %@", errorMessage);
    [self handleServicesReady:NO withMessage:errorMessage];
}

- (void)didConnectToChatServer {
    
    [self chatDidBeginWithChatManager:[BCChatClient sharedInstance]];
}

- (void)didFailToConnectToChatServer:(NSString *)errorMessage {
    
    [self showAlertMessage:errorMessage];
}

@end
