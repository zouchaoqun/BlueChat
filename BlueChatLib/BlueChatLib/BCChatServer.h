//
//  BCChatServer.h
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCChatManagerInterface.h"

@import CoreBluetooth;

/**
 *  The chat server delegate.
 */
@protocol BCChatServerDelegate <NSObject>

/**
 *  The chat server has started successfully.
 */
- (void)chatServerDidStart;

/**
 *  The chat server could not be started.
 *
 *  @param errorMessage The reason of start failure.
 */
- (void)chatServerDidFailToStart:(NSString * _Nonnull)errorMessage;

/**
 *  A chat client did come
 */
- (void)chatClientDidCome;

@end

/**
 *  The BLE chat server (peripheral role). It advertises using the given server name.
 */
@interface BCChatServer : NSObject <BCChatManagerInterface>

/**
 *  Get the shared instance.
 *
 *  @return The shared instance.
 */
+ (nullable instancetype)sharedInstance;

/**
 *  Start the chat server.
 *
 *  @param name                 The server name. If it's longer than @BCConstantMaximumNameLength it will be truncated.
 *  @param chatServerDelegate   The BCChatServerDelegate which implements the chat server related methods
 *  @param chatManagerDelegate  The BCChatManagerDelegate which implements common methods related to both chat server and chat client
 */
- (void)startChatServerWithName:(NSString * _Nonnull)name chatServerDelegate:(id<BCChatServerDelegate> _Nonnull)chatServerDelegate chatManagerDelegate:(id<BCChatManagerDelegate> _Nonnull)chatManagerDelegate;

/**
 *  Stop the chat server.
 */
- (void)stopChatServier;

@end
