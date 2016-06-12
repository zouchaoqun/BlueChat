//
//  BCMessage.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The direction of the message.
 */
typedef NS_ENUM(NSInteger, BCMessageDirection) {
    /**
     *  The message is going to the other party in the chat.
     */
    BCMessageDirectionOutgoing,
    /**
     *  The message is coming from the other party of the chat.
     */
    BCMessageDirectionIncoming
};

/**
 *  The state of the outgoing message.
 */
typedef NS_ENUM(NSInteger, BCMessageOutgoingState) {
    /**
     *  The message is being sent out.
     */
    BCMessageOutgoingStateSending,
    /**
     *  The message has been sent out.
     */
    BCMessageOutgoingStateSent,
    /**
     *  The message has been failed to reach the other party.
     */
    BCMessageOutgoingStateFailed
};

/**
 *  The message.
 */
@interface BCMessage : NSObject

/**
 *  The message text.
 */
@property (copy, nonatomic) NSString * _Nonnull message;

/**
 *  The direction of the message.
 */
@property (nonatomic) BCMessageDirection direction;

/**
 *  The state of the outgoing message. It's undefined for incoming messages.
 */
@property (nonatomic) BCMessageOutgoingState outgoingState;

/**
 *  Initialize the message.
 *
 *  @param message   The message text.
 *  @param direction The direction of the message.
 *
 *  @return The new message instance.
 */
- (nullable instancetype)initWithMessage:(NSString * _Nonnull )message direction:(BCMessageDirection)direction;

@end
