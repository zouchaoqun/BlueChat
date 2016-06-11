//
//  BCMessage.h
//  BlueChatLib
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BCMessageDirection) {
    BCMessageDirectionOutgoing,
    BCMessageDirectionIncoming
};

@interface BCMessage : NSObject


@property (copy, nonatomic) NSString * _Nonnull message;

@property (nonatomic) BCMessageDirection direction;

@property (nonatomic) BOOL hasBeenSent;

- (nullable instancetype)initWithMessage:(NSString * _Nonnull)message direction:(BCMessageDirection)direction;

@end
