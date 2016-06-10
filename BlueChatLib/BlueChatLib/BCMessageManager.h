//
//  BCMessageManager.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCMessage.h"

@interface BCMessageManager : NSObject

+ (nullable instancetype)sharedManager;

- (void)addMessage:(NSString * _Nonnull)message direction:(BCMessageDirection)direction;

- (void)removeAllMessages;

- (NSUInteger)numberOfMessages;

- (BCMessage * _Nullable)messageAtIndex:(NSUInteger)index;

@end
