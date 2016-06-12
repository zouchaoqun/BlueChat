//
//  BCMessageManager.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCMessage.h"

/**
 *  The global message manager which manages the list of all messages of both directions.
 */
@interface BCMessageManager : NSObject

/**
 *  Get the shared manager.
 *
 *  @return The shared manager.
 */
+ (nullable instancetype)sharedManager;

/**
 *  Add a message to the list and return the new message instance.
 *
 *  @param message   The message text.
 *  @param direction The direction of the message.
 *
 *  @return The new message object.
 */
- (BCMessage * _Nullable)addMessage:(NSString * _Nonnull )message direction:(BCMessageDirection)direction;

/**
 *  Remove all messages in the list.
 */
- (void)removeAllMessages;

/**
 *  Number of messages in the list.
 *
 *  @return The number.
 */
- (NSUInteger)numberOfMessages;

/**
 *  Get the message at the given index.
 *
 *  @param index The index of the messgage.
 *
 *  @return The message object or nil if the index is invalid.
 */
- (BCMessage * _Nullable)messageAtIndex:(NSUInteger)index;

@end
