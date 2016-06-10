//
//  BCMessageManager.m
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCMessageManager.h"

@interface BCMessageManager ()

@property (strong, nonatomic) NSMutableArray *messageArray;

@end

@implementation BCMessageManager

+ (instancetype)sharedManager {
    
    static BCMessageManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
        sharedManager.messageArray = [NSMutableArray array];
    });
    return sharedManager;
}

- (void)addMessage:(NSString *)message direction:(BCMessageDirection)direction {
    
    BCMessage *bcMessage = [[BCMessage alloc] initWithMessage:message direction:direction];
    @synchronized (self) {
        [self.messageArray addObject:bcMessage];
    }
}

- (void)removeAllMessages {
    @synchronized (self) {
        [self.messageArray removeAllObjects];
    }
}

- (NSUInteger)numberOfMessages {
    @synchronized (self) {
        return self.messageArray.count;
    }
}

- (BCMessage *)messageAtIndex:(NSUInteger)index {
    @synchronized (self) {
        return (index < self.messageArray.count) ? [self.messageArray objectAtIndex:index] : nil;
    }
}

@end
