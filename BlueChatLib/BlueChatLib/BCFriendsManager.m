//
//  BCFriendsManager.m
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCFriendsManager.h"

@interface BCFriendsManager () <CBPeripheralManagerDelegate>

@end

@implementation BCFriendsManager

+ (instancetype)sharedManager {
    
    static BCFriendsManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (BOOL)startAdvertisingWithName:(NSString *)name {
    
    
    return NO;
}


#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

@end
