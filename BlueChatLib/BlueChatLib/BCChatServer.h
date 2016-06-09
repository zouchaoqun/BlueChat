//
//  BCChatServer.h
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end

/**
 *  The BLE chat server (peripheral role). It advertises using the given server name.
 */
@interface BCChatServer : NSObject

/**
 *  Get the shared instance.
 *
 *  @return The shared instance.
 */
+ (nullable instancetype)sharedInstance;

/**
 *  Start the chat server.
 *
 *  @param name     The server name. If it's longer than @BCConstantMaximumNameLength it will be truncated.
 *  @param delegate The BCChatServerDelegate
 */
- (void)startChatServerWithName:(NSString * _Nonnull)name delegate:(id<BCChatServerDelegate> _Nonnull)delegate;

/**
 *  Stop the chat server.
 */
- (void)stopChatServier;

@end
