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

/**
 *  The global chat server info manager which manages two lists of all chat servers. One list is for the friend servers, i.e. the servers have been added as a friend. The other list is for the nonfriend servers, i.e. which are found to be advertising but haven't been added as a friend.
 *
 *  Some methods take a isFriend parameter which specifies which list to use in the method.
 */
@interface BCChatServerInfoManager : NSObject

/**
 *  Get the shared manager.
 *
 *  @return The shared manager.
 */
+ (nullable instancetype)sharedManager;

/**
 *  Add a server info entry to the nonfriend server list and return the new server info instance.
 *
 *  @param peripheral The peripheral representing the server.
 *  @param serverName The server name.
 *
 *  @return The new server info instance.
 */
- (BCChatServerInfo * _Nullable)addServer:(CBPeripheral * _Nonnull )peripheral name:(NSString * _Nonnull )serverName;

/**
 *  Check if the peripheral has already been added to either of the server info lists.
 *
 *  @param peripheral The peripheral to check
 *
 *  @return YES if the peripheral is in either of the lists.
 */
- (BOOL)hasPeripheral:(CBPeripheral * _Nonnull )peripheral;

/**
 *  Get the server name related to the peripheral based on the UUID. It can also be used by the BCChatClient if the peripheral is now trying to connect as central role.
 *
 *  @param uuid UUID of the peripheral
 *
 *  @return The server name if the peripheral/central is found in either list, or localized "unknown" otherwise.
 */
- (NSString * _Nonnull )serverNameForPeripheral:(NSUUID * _Nonnull )uuid;

/**
 *  Remove all the server info entries which are not marked as friends, i.e. from the nonfriend server list.
 */
- (void)removeAllNonFriendServers;

/**
 *  Get the number of server info entries matching the isFriend parameter.
 *
 *  @param isFriend Yes to only get the servers which are friends. No to only get the servers which are not friends.
 *
 *  @return The number.
 */
- (NSUInteger)numberOfServers:(BOOL)isFriend;

/**
 *  Get the server info at the given index matching the isFriend parameter.
 *
 *  @param index    The index of the server.
 *  @param isFriend Yes to get the server which is a friend. No to get the server which is not a friend.
 *
 *  @return The server info instance.
 */
- (BCChatServerInfo * _Nullable)serverAtIndex:(NSUInteger)index isFriend:(BOOL)isFriend;

/**
 *  Mark the server which is currently not a friend to be a friend. The underlying process is to find the nonfriend server at the given index in the nonfriend server list then add it to the friend server list. The server will still remain in the nonfriend server list.
 *
 *  @param index The index of the nonfriend server.
 */
- (void)makeServerFriend:(NSUInteger)index;

@end
