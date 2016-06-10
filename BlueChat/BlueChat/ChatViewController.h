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

@property (strong, nonatomic) id<BCChatManagerInterface> chatManager;

@end
