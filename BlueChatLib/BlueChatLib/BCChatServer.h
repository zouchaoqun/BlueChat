//
//  BCChatServer.h
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCChatManagerInterface.h"

/**
 *  The chat server delegate which receives the chat server statuses and events.
 */
@protocol BCChatServerDelegate <NSObject>

/**
 *  The chat server has started successfully.
 */
- (void)chatServerDidStart;

/**
 *  The chat server could not be started or has been interrupted.
 *
 *  @param errorMessage The reason of the failure.
 */
- (void)chatServerDidFail:(NSString * _Nonnull )errorMessage;

/**
 *  A chat client did come.
 *
 *  @param clientName The client name if it can be found in BCServerInfoManager based on its UUID or empty string if not.
 */
- (void)chatClientDidCome:(NSString * _Nonnull )clientName;

@end

/**
 *  The BLE chat server (peripheral role). It advertises using the given server name.
 */
@interface BCChatServer : NSObject <BCChatManagerInterface>

/**
 *  If the chat server is ready to advertise.
 */
@property (nonatomic) BOOL isChatServerReady;

/**
 *  Get the shared instance.
 *
 *  @return The shared instance.
 */
+ (nullable instancetype)sharedInstance;

/**
 *  Initialize and start the chat server. The chat server will call BCChatServerDelegate methods to report its status.
 *
 *  @param name                 The server name. If it's longer than @BCConstantMaximumNameLength it will be truncated.
 *  @param chatServerDelegate   The BCChatServerDelegate which implements the chat server delegate related methods.
 *  @param chatManagerDelegate  The BCChatManagerDelegate which implements the common delegate methods related to both chat server and chat client.
 */
- (void)initChatServerWithName:(NSString * _Nonnull )name chatServerDelegate:(id<BCChatServerDelegate> _Nonnull )chatServerDelegate chatManagerDelegate:(id<BCChatManagerDelegate> _Nonnull )chatManagerDelegate;

/**
 *  Pause the chat server, i.e. stops the advertising. The chat server will call BCChatServerDelegate methods to report its status.
 */
- (void)pauseChatServier;

/**
 *  Resume the chat server, i.e. restarts the advertising. The chat server will call BCChatServerDelegate methods to report its status.
 */
- (void)resumeChatServer;

@end
