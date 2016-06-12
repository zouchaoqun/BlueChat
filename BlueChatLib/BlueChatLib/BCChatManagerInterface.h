//
//  BCChatManagerInterface.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#ifndef BCChatManagerInterface_h
#define BCChatManagerInterface_h

#import "BCMessage.h"

/**
 *  The chat manager delegate which receives new events from the chat manager.
 */
@protocol BCChatManagerDelegate <NSObject>

/**
 *  There is a new message from the other party in the chat. Check BCMessageManager for all the messages.
 */
- (void)newMessageDidCome;

/**
 *  The other part in the chat has left the chat. The chat is ended.
 */
- (void)chatRoomDidClose;

@end

/**
 *  The abstract chat manager which takes care of the common chat tasks no matter the app is acting as Central or Peripheral role. The chat manager will call BCChatManagerDelegate methods to reports events.
 */
@protocol BCChatManagerInterface <NSObject>

/**
 *  Send a message to the other party in the chat. The sending status of the message will be updated in the BCMessage object managed by BCMessageManager.
 *
 *  @param bcMessage The message object.
 */
- (void)sendMessage:(BCMessage * _Nonnull )bcMessage;

/**
 *  Leave the chat room and end the chat.
 */
- (void)leaveChatroom;

@end

#endif /* BCChatManagerInterface_h */
