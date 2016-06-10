//
//  BCMessage.m
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCMessage.h"

@implementation BCMessage

- (instancetype)initWithMessage:(NSString *)message direction:(BCMessageDirection)direction {
    
    if (self = [super init]) {
        self.message = message;
        self.direction = direction;
    }
    return self;
}

@end
