//
//  BCFriendsManager.h
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

@interface BCFriendsManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)startAdvertisingWithName:(NSString *)name;


@end
