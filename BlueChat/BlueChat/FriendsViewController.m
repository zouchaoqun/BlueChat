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

@interface FriendsViewController () <BCChatServerDelegate>

@property (strong, nonatomic) ChatViewController *chatViewController;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendBarButton;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // we need to create the chatViewController now so it can be passed as chatManagerDelegate to BCChatServer
    // otherwise in edge cases the chatRoomDidClose message might be missed
    self.chatViewController = [self createChatViewController];
    
    [[BCChatServer sharedInstance] initChatServerWithName:@"abcdefgh12345678" chatServerDelegate:self chatManagerDelegate:self.chatViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (ChatViewController *)createChatViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
}

- (void)handleServicesReady:(BOOL)ready withMessage:(NSString *)message {
    
    self.errorMessageLabel.text = message;
    self.errorMessageLabel.hidden = ready;
    self.friendsTableView.hidden = !ready;
    self.addFriendBarButton.enabled = ready;
}

#pragma mark - BCChatServerDelegate

- (void)chatServerDidStart {
    
    NSLog(@"chat server started");
    [self handleServicesReady:YES withMessage:@""];
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
    
    self.chatViewController.chatManager = [BCChatServer sharedInstance];
    [self.navigationController pushViewController:self.chatViewController animated:YES];
}



@end
