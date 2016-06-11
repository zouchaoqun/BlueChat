//
//  BCChatServerInfoManager.h
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCChatServerInfo.h"

@import CoreBluetooth;

@interface BCChatServerInfoManager : NSObject

+ (nullable instancetype)sharedManager;

- (BCChatServerInfo * _Nullable)addServer:(CBPeripheral * _Nonnull )peripheral name:(NSString * _Nonnull )serverName;

- (BOOL)hasPeripheral:(CBPeripheral * _Nonnull )peripheral;

- (void)removeAllNonFriendServers;

- (NSUInteger)numberOfServers:(BOOL)isFriend;

- (BCChatServerInfo * _Nullable)serverAtIndex:(NSUInteger)index isFriend:(BOOL)isFriend;

- (void)makeServerFriend:(NSUInteger)index;

@end
