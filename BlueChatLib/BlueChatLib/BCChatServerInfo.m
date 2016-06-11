//
//  BCChatServerInfo.m
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCChatServerInfo.h"

@implementation BCChatServerInfo

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral name:(NSString *)name {
    
    if (self = [super init]) {
        
        self.name = name;
        self.peripheral = peripheral;
    }
    return self;
}

@end
