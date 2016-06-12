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
#import "SimpleLoadingHud.h"

@interface FriendsViewController () <BCChatServerDelegate, BCChatClientDelegate, UITableViewDataSource, UITextFieldDelegate>

/**
 *  The chat view controller. It's created beforehand to simplify the logic of ensuring we don't miss the events from the BCChatServer.
 */
@property (strong, nonatomic) ChatViewController *chatViewController;

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendBarButton;

/**
 *  The name of the chat server.
 */
@property (copy, nonatomic) NSString *myName;

/**
 *  The UIAlertAction in the alert we use to ask for server name. It's a property since we want to enable/disable it based on the text input.
 */
@property (weak, nonatomic) UIAlertAction *nameAlertOkAction;

@end

@implementation FriendsViewController

static NSString *const FriendsTableViewCellReuseIdentifier = @"FriendsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.myName) {
        // ask for the name if we haven't got it. we don't save the name currently so it asks everytime app is launched
        [self askForName];
    }
    else {
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
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Please enter your name so your friends can find you.\nMaximum %li characters.", @""), BCConstantMaximumNameLength];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.delegate = self;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    // allow delete
    if (string.length == 0) {
        return YES;
    }
    
    NSInteger newLength = textField.text.length + range.length + string.length;
    return newLength <= BCConstantMaximumNameLength;
}

#pragma mark - Helpers
- (void)startServices {
    
    // we need to create the chatViewController now so it can be passed as chatManagerDelegate to BCChatServer
    // otherwise in edge cases the chatRoomDidClose message might be missed. There might be better method but this is used as a simplified
    // logic in this demo app.
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

- (void)chatDidBeginWithChatManager:(id<BCChatManagerInterface>)chatManager andOtherParty:(NSString *)otherPartyName {
    [[BCChatServer sharedInstance] pauseChatServier];
    
    self.chatViewController.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Chat with %@", @""), otherPartyName];
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
        [SimpleLoadingHud showHudInView:self.navigationController.view];
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

- (void)chatClientDidCome:(NSString *)clientName {
    
    if (self.navigationController.topViewController == self.chatViewController) {
        NSLog(@"already chatting");
        return;
    }
    
    [self chatDidBeginWithChatManager:[BCChatServer sharedInstance] andOtherParty:clientName];
}


#pragma mark - BCChatClientDelegate
- (void)chatClientDidBecomeReady {
    
    NSLog(@"chat client ready");
    if ([BCChatServer sharedInstance].isChatServerReady) {
        [self handleServicesReady:YES withMessage:@""];
    }
}

- (void)chatClientDidBecomeUnready:(NSString *)errorMessage {
    
    NSLog(@"chat client unready %@", errorMessage);
    [self handleServicesReady:NO withMessage:errorMessage];
}

- (void)didConnectToChatServer:(NSString *)serverName {
    
    [SimpleLoadingHud hidHudInView:self.navigationController.view];
    [self chatDidBeginWithChatManager:[BCChatClient sharedInstance] andOtherParty:serverName];
}

- (void)didFailToConnectToChatServer:(NSString *)errorMessage {
    
    [SimpleLoadingHud hidHudInView:self.navigationController.view];
    [self showAlertMessage:errorMessage];
}

@end
