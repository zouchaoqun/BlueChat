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

@protocol BCChatClientDelegate <NSObject>

- (void)chatClientDidBecomeReady;

- (void)chatClientDidBecomeUnready:(NSString * _Nonnull )errorMessage;

@end

@protocol BCChatServerSearchResultDelegate <NSObject>

- (void)didFindChatServer;

- (void)searchInterrupted;

@end

@interface BCChatClient : NSObject

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

- (void)searchForChatServerWithDelegate:(id<BCChatServerSearchResultDelegate> _Nonnull )searchResultDelegate;

- (void)stopSearchingForChatServer;

- (void)connectToChatServer;

@end
