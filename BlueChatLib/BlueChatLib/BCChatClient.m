//
//  BCChatClient.m
//  BlueChatLib
//
//  Created by Max Zou on 11/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCChatClient.h"
#import "BCConstants.h"
#import "BCChatServerInfoManager.h"

@import CoreBluetooth;

@interface BCChatClient () <CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (weak, nonatomic) id<BCChatClientDelegate> chatClientDelegate;

@property (weak, nonatomic) id<BCChatManagerDelegate> chatManagerDelegate;

@property (weak, nonatomic) id<BCChatServerSearchResultDelegate> searchResultDelegate;

@end

@implementation BCChatClient

+ (instancetype)sharedInstance {
    
    static BCChatClient *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initChatClientWithDelegate:(id<BCChatClientDelegate>)chatClientDelegate chatManagerDelegate:(id<BCChatManagerDelegate>)chatManagerDelegate {
 
    self.chatClientDelegate = chatClientDelegate;
    self.chatManagerDelegate = chatManagerDelegate;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)searchForChatServerWithDelegate:(id<BCChatServerSearchResultDelegate>)searchResultDelegate {
    
    NSLog(@"search....");
    
    [[BCChatServerInfoManager sharedManager] removeAllNonFriendServers];
    
    self.searchResultDelegate = searchResultDelegate;
    [self.centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:BCChatServiceUUID] ] options:nil];
}

- (void)stopSearchingForChatServer {
    
    NSLog(@"stop searching");
    [self.centralManager stopScan];
}

- (void)connectToChatServer {
    
}

#pragma mark - Helpers

- (void)reportFailedWithReason:(NSString *)reason {
    
    self.isChatClientReady = NO;
    [self.chatClientDelegate chatClientDidBecomeUnready:reason];
    [self.chatManagerDelegate chatRoomDidClose];
    [self.searchResultDelegate searchInterrupted];
}

- (void)reportChatClientReady {
    
    self.isChatClientReady = YES;
    [self.chatClientDelegate chatClientDidBecomeReady];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self reportChatClientReady];
            break;
            
        case CBCentralManagerStatePoweredOff:
            [self reportFailedWithReason:NSLocalizedString(@"Please enable Bluetooth then try again.", @"")];
            break;
            
        case CBCentralManagerStateUnsupported:
            [self reportFailedWithReason:NSLocalizedString(@"You device does not support this app.", @"")];
            break;
            
        case CBCentralManagerStateUnauthorized:
            [self reportFailedWithReason:NSLocalizedString(@"Please authorize this app to use Bluetooth then try again.", @"")];
            break;
            
        default:
            // other temporary states are ignored
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {

    // we won't add the same peripheral again
    if ([[BCChatServerInfoManager sharedManager] hasPeripheral:peripheral]) {
        return;
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    // if no local name it means CoreBluetooth hasn't got it and we should get it again soon
    if (!localName) {
        return;
    }
    
    BCChatServerInfo *serverInfo = [[BCChatServerInfoManager sharedManager] addServer:peripheral name:localName];
    
    if (self.searchResultDelegate) {
        [self.searchResultDelegate didFindChatServer];
    }
}

@end
