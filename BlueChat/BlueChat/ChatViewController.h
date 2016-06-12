//
//  ChatViewController.h
//  BlueChat
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BlueChatLib/BlueChatLib.h>

@interface ChatViewController : UIViewController <BCChatManagerDelegate>

/**
 *  The chat manager. It's a property because it can be either the chat server or the chat client and it needs to be set in FriendsViewController when a chat begins.
 */
@property (strong, nonatomic) id<BCChatManagerInterface> chatManager;

@end
