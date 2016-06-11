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

@property (copy, nonatomic) NSString * _Nonnull name;

@property (strong, nonatomic) CBPeripheral * _Nonnull peripheral;

- (nullable instancetype)initWithPeripheral:(CBPeripheral * _Nonnull )peripheral name:(NSString * _Nonnull )name;

@end
