//
//  BCChatManagerInterface.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#ifndef BCChatManagerInterface_h
#define BCChatManagerInterface_h


@protocol BCChatManagerDelegate <NSObject>

- (void)newMessageDidCome;

- (void)chatRoomDidClose;

@end


@protocol BCChatManagerInterface <NSObject>

- (void)sendMessage:(NSString * _Nonnull)message;

- (void)leaveChatroom;

@end

#endif /* BCChatManagerInterface_h */
