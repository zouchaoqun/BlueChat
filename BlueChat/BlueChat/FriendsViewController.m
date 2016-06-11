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

@property (copy, nonatomic) NSString *myName;

@property (weak, nonatomic) UIAlertAction *nameAlertOkAction;

@end

@implementation FriendsViewController

static NSString *const FriendsTableViewCellReuseIdentifier = @"FriendsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // we need to create the chatViewController now so it can be passed as chatManagerDelegate to BCChatServer
    // otherwise in edge cases the chatRoomDidClose message might be missed
    [self askForName];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.myName) {
    
        [self.friendsTableView reloadData];

        // BCChatServer will take care of whether it can resume
        [[BCChatServer sharedInstance] resumeChatServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Ask for name
- (void)askForName {
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Please enter your name so your friends can find you.\nName needs to be no more than %li characters.", @""), BCConstantMaximumNameLength];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [textField addTarget:self action:@selector(nameTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    self.nameAlertOkAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert.textFields[0] removeTarget:self action:@selector(nameTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        self.myName = alert.textFields[0].text;
        
        [self startServices];
    }];
    
    self.nameAlertOkAction.enabled = NO;
    [alert addAction:self.nameAlertOkAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)nameTextFieldChanged:(UITextField *)textField {
    
    if (!self.nameAlertOkAction) {
        return;
    }
    
    if (textField.text.length > 0 && textField.text.length <= BCConstantMaximumNameLength) {
        self.nameAlertOkAction.enabled = YES;
    }
    else {
        self.nameAlertOkAction.enabled = NO;
    }
}

#pragma mark - Helpers
- (void)startServices {
    
    self.chatViewController = [self createChatViewController];
    
    [[BCChatServer sharedInstance] initChatServerWithName:self.myName chatServerDelegate:self chatManagerDelegate:self.chatViewController];
    
    [[BCChatClient sharedInstance] initChatClientWithDelegate:self chatManagerDelegate:self.chatViewController];
}

- (ChatViewController *)createChatViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
}

- (void)handleServicesReady:(BOOL)ready withMessage:(NSString *)message {
    
    if (!self.myName) {
        ready = NO;
    }
    
    self.errorMessageLabel.text = message;
    self.errorMessageLabel.hidden = ready;
    self.friendsTableView.hidden = !ready;
    self.addFriendBarButton.enabled = ready;
    
    [self.friendsTableView reloadData];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Message", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
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
