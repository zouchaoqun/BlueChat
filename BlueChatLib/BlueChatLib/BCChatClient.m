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
#import "BCMessageManager.h"

@import CoreBluetooth;

@interface BCChatClient () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (weak, nonatomic) id<BCChatClientDelegate> chatClientDelegate;

@property (weak, nonatomic) id<BCChatManagerDelegate> chatManagerDelegate;

@property (weak, nonatomic) id<BCChatServerSearchResultDelegate> searchResultDelegate;

@property (strong, nonatomic) CBPeripheral *activePeripheral;

@property (strong, nonatomic) CBCharacteristic *centralToPeripheralCharacteristic;

@property (strong, nonatomic) NSTimer *connectionTimeoutTimer;

@property (nonatomic) BOOL peripheralToCentralNotificationEnabled;

@property (nonatomic) BOOL peripheralDisconnectNotificationEnabled;

@property (strong, nonatomic) NSMutableArray *outgoingMessageArray;

@end

@implementation BCChatClient

static const NSTimeInterval ConnectionTimeoutTime = 3;

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

- (void)connectToChatServer:(BCChatServerInfo *)serverInfo {
    
    if (serverInfo.peripheral) {
        
        // we will cancel the previous connection if there is one and it's not disconnected
        if (self.activePeripheral && self.activePeripheral.state != CBPeripheralStateDisconnected) {
            [self.centralManager cancelPeripheralConnection:self.activePeripheral];
        }
        
        self.peripheralToCentralNotificationEnabled = NO;
        self.peripheralDisconnectNotificationEnabled = NO;
        
        self.activePeripheral = serverInfo.peripheral;
        [self.centralManager connectPeripheral:self.activePeripheral options:nil];
    }
}

#pragma mark - BCChatManagerInterface
- (void)sendMessage:(BCMessage *)bcMessage {
    
    if (self.activePeripheral && self.activePeripheral.state == CBPeripheralStateConnected && self.centralToPeripheralCharacteristic) {

        NSData *data = [bcMessage.message dataUsingEncoding:NSUTF8StringEncoding];
        bcMessage.outgoingState = BCMessageOutgoingStateSending;
        
        [self.outgoingMessageArray addObject:bcMessage];
        
        [self.activePeripheral writeValue:data forCharacteristic:self.centralToPeripheralCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    else {
        bcMessage.outgoingState = BCMessageOutgoingStateFailed;
    }
}

- (void)leaveChatroom {
    if (self.activePeripheral && self.activePeripheral.state != CBPeripheralStateDisconnected) {
        [self.centralManager cancelPeripheralConnection:self.activePeripheral];
    }
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

- (void)reportConnectedToServer {
    
    self.outgoingMessageArray = [NSMutableArray array];
    
    [self stopConnectionTimeoutTimer];
    
    [self.chatClientDelegate didConnectToChatServer];
}

- (void)reportFailedToConnectToServer:(NSString *)reason {
    
    [self stopConnectionTimeoutTimer];
    
    if (self.activePeripheral && self.activePeripheral.state != CBPeripheralStateDisconnected) {
        [self.centralManager cancelPeripheralConnection:self.activePeripheral];
    }
    
    [self.chatClientDelegate didFailToConnectToChatServer:reason];
    [self.chatManagerDelegate chatRoomDidClose];
}

- (void)startConnectionTimeoutTimer {
    if (self.connectionTimeoutTimer) {
        [self.connectionTimeoutTimer invalidate];
    }
    self.connectionTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:ConnectionTimeoutTime target:self selector:@selector(connectionTimedout:) userInfo:nil repeats:NO];
}

- (void)stopConnectionTimeoutTimer {
    if (self.connectionTimeoutTimer) {
        [self.connectionTimeoutTimer invalidate];
        self.connectionTimeoutTimer = nil;
    }
}

- (void)connectionTimedout:(NSTimer *)timer {
    [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. Timed out.", @"")];
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

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    if (peripheral == self.activePeripheral) {
        //[self reportConnectedToServer];
        [self.activePeripheral setDelegate:self];
        [self.activePeripheral discoverServices:@[ [CBUUID UUIDWithString:BCChatServiceUUID] ]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
    if (peripheral == self.activePeripheral) {
        [self.chatManagerDelegate chatRoomDidClose];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (peripheral == self.activePeripheral) {
        [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server.", @"")];
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (peripheral == self.activePeripheral) {
        
        if (error) {
            [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. No service.", @"")];
            return;
        }
        
        BOOL serviceFound = NO;
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:BCChatServiceUUID]) {
                [peripheral discoverCharacteristics:nil forService:service];
                serviceFound = YES;
                break;
            }
        }
        
        if (!serviceFound) {
            [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. No service.", @"")];
            return;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (peripheral == self.activePeripheral) {
        if ([service.UUID.UUIDString isEqualToString:BCChatServiceUUID]) {
            
            if (error) {
                [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. Service error.", @"")];
                return;
            }
            
            BOOL centralToPeripheralFound = NO;
            BOOL peripheralToCentralFound = NO;
            BOOL peripheralDisconnectFound = NO;
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:BCChatCentralToPeripheralCharacteristicUUID]) {
                    self.centralToPeripheralCharacteristic = characteristic;
                    centralToPeripheralFound = YES;
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralCharacteristicUUID]) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    peripheralToCentralFound = YES;
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID]) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    peripheralDisconnectFound = YES;
                }
            }
            
            if (!centralToPeripheralFound || !peripheralToCentralFound || !peripheralDisconnectFound) {
                [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. Service error.", @"")];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (peripheral == self.activePeripheral) {
        
        if ([characteristic.service.UUID.UUIDString isEqualToString:BCChatServiceUUID]) {
            if (error) {
                [self reportFailedToConnectToServer:NSLocalizedString(@"Could not connect to the server. Service error.", @"")];
                return;
            }
        }
        
        if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralCharacteristicUUID]) {
            self.peripheralToCentralNotificationEnabled = YES;
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID]) {
            self.peripheralDisconnectNotificationEnabled = YES;
        }
        
        if (self.peripheralToCentralNotificationEnabled && self.peripheralDisconnectNotificationEnabled) {
            [self reportConnectedToServer];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (peripheral == self.activePeripheral) {
        
        if ([characteristic.UUID.UUIDString isEqualToString:BCChatCentralToPeripheralCharacteristicUUID]) {
            
            // we try to get the first message and set its outgoing state
            if (self.outgoingMessageArray.count > 0) {
                BCMessage *bcMessage = [self.outgoingMessageArray firstObject];
                if (bcMessage) {
                    bcMessage.outgoingState = (error == nil) ? BCMessageOutgoingStateSent : BCMessageOutgoingStateFailed;
                }
                [self.outgoingMessageArray removeObjectAtIndex:0];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (peripheral == self.activePeripheral) {
        
        if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralCharacteristicUUID]) {
            if (characteristic.value) {
                NSString *message = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                if (message) {
                    [[BCMessageManager sharedManager] addMessage:message direction:BCMessageDirectionIncoming];
                    [self.chatManagerDelegate newMessageDidCome];
                }
            }
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID]) {
            // peripheral requests to disconnect
            [self leaveChatroom];
        }
        
    }
}

@end
