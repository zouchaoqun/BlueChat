//
//  BCChatClient.h
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCChatClient : NSObject

- (void)searchForChatServer;

- (void)stopSearchingForChatServer;

- (void)connectToChatServer;

@end
