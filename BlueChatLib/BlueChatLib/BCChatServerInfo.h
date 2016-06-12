//
//  BCChatServerInfo.h
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

/**
 *  Information of a chat server like identifier, name etc
 */
@interface BCChatServerInfo : NSObject

/**
 *  Name of the chat server as reported in advertisement's Local Name field by the server.
 */
@property (copy, nonatomic) NSString * _Nonnull name;

/**
 *  The CBPeripheral instance representing the server.
 */
@property (strong, nonatomic) CBPeripheral * _Nonnull peripheral;

/**
 *  Initialize the server info instance.
 *
 *  @param peripheral The CBPeripheral representing the server.
 *  @param name       The name of the server.
 *
 *  @return The server info instance.
 */
- (nullable instancetype)initWithPeripheral:(CBPeripheral * _Nonnull )peripheral name:(NSString * _Nonnull )name;

@end
