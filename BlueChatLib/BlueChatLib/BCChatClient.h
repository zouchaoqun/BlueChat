//
//  BCChatClient.h
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCChatManagerInterface.h"
#import "BCChatServerInfo.h"

/**
 *  The chat client delegate which receives the chat client statuses and events.
 */
@protocol BCChatClientDelegate <NSObject>

/**
 *  The chat client is ready to search for friends or connect to a friend.
 */
- (void)chatClientDidBecomeReady;

/**
 *  The chat client becomes not ready to perform its tasks, e.g. the Bluetooth has been disabled.
 *
 *  @param errorMessage The reason of why it's unready.
 */
- (void)chatClientDidBecomeUnready:(NSString * _Nonnull )errorMessage;

/**
 *  The chat client has connected to the chat server.
 */
- (void)didConnectToChatServer;

/**
 *  The chat client could not connect to the chat server, 
 *
 *  @param errorMessage The reason that it could not connect to the server, e.g. timeout, could not discover necessary service or characteristics, could not enable indication on the required characteristics etc.
 */
- (void)didFailToConnectToChatServer:(NSString * _Nonnull )errorMessage;

@end

/**
 *  The delegate which receives the results of the chat server searching, and events from the searching process.
 */
@protocol BCChatServerSearchResultDelegate <NSObject>

/**
 *  One or more chat servers have been found and put into BCChatServerInfoManager.
 */
- (void)didFindChatServer;

/**
 *  Search has been interrupted and can not continue by itself, e.g. Bluetooth has been disabled.
 */
- (void)searchInterrupted;

@end

/**
 *  The BLE chat client (central role). It takes care of finding chat servers and connecting to a chat server.
 */
@interface BCChatClient : NSObject <BCChatManagerInterface>

/**
 *  If the chat client is ready to perform its tasks.
 */
@property (nonatomic) BOOL isChatClientReady;

/**
 *  Get the shared instance.
 *
 *  @return The shared instance.
 */
+ (nullable instancetype)sharedInstance;

/**
 *  Initialize the chat client.
 *
 *  @param chatClientDelegate   The BCChatClientDelegate which implements the chat client delegate related methods
 *  @param chatManagerDelegate  The BCChatManagerDelegate which implements common delegate methods related to both chat server and chat client
 */
- (void)initChatClientWithDelegate:(id<BCChatClientDelegate> _Nonnull )chatClientDelegate chatManagerDelegate:(id<BCChatManagerDelegate> _Nonnull )chatManagerDelegate;

/**
 *  Search for chat servers. 
 *
 *  @param searchResultDelegate The BCChatServerSearchResultDelegate which receives search results and events.
 */
- (void)searchForChatServerWithDelegate:(id<BCChatServerSearchResultDelegate> _Nonnull )searchResultDelegate;

/**
 *  Stop searching for chat servers.
 */
- (void)stopSearchingForChatServer;

/**
 *  Connect to the chat server.
 *
 *  @param serverInfo The info of the chat server.
 */
- (void)connectToChatServer:(BCChatServerInfo * _Nonnull )serverInfo;

@end
