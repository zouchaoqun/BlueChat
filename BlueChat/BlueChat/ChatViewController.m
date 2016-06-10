//
//  ChatViewController.m
//  BlueChat
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "ChatViewController.h"

@implementation ChatViewController


- (IBAction)sendMessage:(id)sender {
    
    [self.chatManager sendMessage:@"hello how are you"];
}

#pragma mark - BCChatManagerDelegate
- (void)newMessageDidCome {
    
}

- (void)chatRoomDidClose {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
