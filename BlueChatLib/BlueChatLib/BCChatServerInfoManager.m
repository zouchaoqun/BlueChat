//
//  BCChatServerInfoManager.m
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCChatServerInfoManager.h"

@interface BCChatServerInfoManager ()

@property (strong, nonatomic) NSMutableArray *friendServerArray;

@property (strong, nonatomic) NSMutableArray *nonFriendServerArray;

@end

@implementation BCChatServerInfoManager

+ (instancetype)sharedManager {
    
    static BCChatServerInfoManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
        sharedManager.friendServerArray = [NSMutableArray array];
        sharedManager.nonFriendServerArray = [NSMutableArray array];
    });
    return sharedManager;
}

- (BCChatServerInfo *)addServer:(CBPeripheral *)peripheral name:(NSString *)serverName {

    BCChatServerInfo *info = [[BCChatServerInfo alloc] initWithPeripheral:peripheral name:serverName];
    if (!info) {
        return nil;
    }
    
    @synchronized (self) {
        [self.nonFriendServerArray addObject:info];
        return info;
    }
}

- (BOOL)hasPeripheral:(CBPeripheral *)peripheral {
    
    return ([self findServerInfoInArray:self.friendServerArray byPeripheralIdentifier:peripheral.identifier] != nil) || ([self findServerInfoInArray:self.nonFriendServerArray byPeripheralIdentifier:peripheral.identifier] != nil);
}

- (NSString *)serverNameForPeripheral:(NSUUID *)uuid {
    
    BCChatServerInfo *info = [self findServerInfoInArray:self.friendServerArray byPeripheralIdentifier:uuid];
    if (info) {
        return info.name;
    }
    
    info = [self findServerInfoInArray:self.nonFriendServerArray byPeripheralIdentifier:uuid];
    if (info) {
        return info.name;
    }
    return NSLocalizedString(@"(unknown)", @"");
}

- (void)removeAllNonFriendServers {
    @synchronized (self) {
        [self.nonFriendServerArray removeAllObjects];
    }
}

- (NSUInteger)numberOfServers:(BOOL)isFriend {
    
    @synchronized (self) {
        
        NSMutableArray *array = isFriend ? self.friendServerArray : self.nonFriendServerArray;
        return array.count;
    }
}

- (BCChatServerInfo *)serverAtIndex:(NSUInteger)index isFriend:(BOOL)isFriend {
    
    @synchronized (self) {
        
        NSMutableArray *array = isFriend ? self.friendServerArray : self.nonFriendServerArray;
        return (index < array.count) ? [array objectAtIndex:index] : nil;
    }
}

- (void)makeServerFriend:(NSUInteger)index {
    
    @synchronized (self) {
        
        BCChatServerInfo *info = (index < self.nonFriendServerArray.count) ? [self.nonFriendServerArray objectAtIndex:index] : nil;
        if (info) {
            [self.friendServerArray addObject:info];
        }
    }
}

#pragma mark - Helpers
- (BCChatServerInfo *)findServerInfoInArray:(NSArray *)array byPeripheralIdentifier:(NSUUID *)identifier {
    
    for (BCChatServerInfo *info in array) {
        if ([info.peripheral.identifier isEqual:identifier]) {
            return info;
        }
    }
    return nil;
}


@end
