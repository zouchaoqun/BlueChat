//
//  BCChatServer.m
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCChatServer.h"
#import "BCConstants.h"
#import "BCMessageManager.h"
@import CoreBluetooth;

@interface BCChatServer () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@property (strong, nonatomic) CBMutableService *chatService;

@property (strong, nonatomic) CBMutableCharacteristic *centralToPeripheralCharacteristic;

@property (strong, nonatomic) CBMutableCharacteristic *peripheralToCentralCharacteristic;

@property (strong, nonatomic) CBMutableCharacteristic *peripheralToCentralDisconnectRequestCharacteristic;

@property (copy, nonatomic) NSString *serverName;

@property (weak, nonatomic) id<BCChatServerDelegate> chatServerDelegate;

@property (weak, nonatomic) id<BCChatManagerDelegate> chatManagerDelegate;

@end

@implementation BCChatServer

+ (instancetype)sharedInstance {
    
    static BCChatServer *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initChatServerWithName:(NSString *)name chatServerDelegate:(id<BCChatServerDelegate> _Nonnull )chatServerDelegate chatManagerDelegate:(id<BCChatManagerDelegate> _Nonnull )chatManagerDelegate {
    
    self.chatServerDelegate = chatServerDelegate;
    self.chatManagerDelegate = chatManagerDelegate;
    
    if (name.length <= BCConstantMaximumNameLength) {
        self.serverName = name;
    }
    else {
        self.serverName = [name substringToIndex:BCConstantMaximumNameLength];
    }
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)pauseChatServier {
    
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
    }
}

- (void)resumeChatServer {
    if (!self.peripheralManager.isAdvertising) {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[self.chatService.UUID], CBAdvertisementDataLocalNameKey : self.serverName}];
    }
    else {
        [self reportChatServerReady];
    }
}

#pragma mark - BCChatManagerInterface
- (void)sendMessage:(BCMessage *)bcMessage {
    
    NSData *data = [bcMessage.message dataUsingEncoding:NSUTF8StringEncoding];
    bcMessage.hasBeenSent = [self.peripheralManager updateValue:data forCharacteristic:self.peripheralToCentralCharacteristic onSubscribedCentrals:nil];
}

- (void)leaveChatroom {
    Byte bytes[1] = {0x01};
    NSData *data = [NSData dataWithBytes:bytes length:1];
    [self.peripheralManager updateValue:data forCharacteristic:self.peripheralToCentralDisconnectRequestCharacteristic onSubscribedCentrals:nil];
}

#pragma mark - Helpers
- (void)setupServiceCharacteristics {
    
    self.chatService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BCChatServiceUUID] primary:YES];
    
    self.centralToPeripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BCChatCentralToPeripheralCharacteristicUUID] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];

    self.peripheralToCentralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BCChatPeripheralToCentralCharacteristicUUID] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyIndicate value:nil permissions:CBAttributePermissionsReadable];

    self.peripheralToCentralDisconnectRequestCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyIndicate value:nil permissions:CBAttributePermissionsReadable];
    
    self.chatService.characteristics = @[self.centralToPeripheralCharacteristic, self.peripheralToCentralCharacteristic, self.peripheralToCentralDisconnectRequestCharacteristic];
    
    [self.peripheralManager addService:self.chatService];
}

- (void)reportFailedWithReason:(NSString *)reason {
    
    self.isChatServerReady = NO;
    [self.chatServerDelegate chatServerDidFail:reason];
    [self.chatManagerDelegate chatRoomDidClose];
}

- (void)reportChatServerReady {
    
    self.isChatServerReady = YES;
    [self.chatServerDelegate chatServerDidStart];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager {

    NSLog(@"did update state %li", (long)peripheralManager.state);
    
    switch (peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOn:
            if (!self.chatService) {
                [self setupServiceCharacteristics];
            }
            else {
                [self resumeChatServer];
            }
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            [self reportFailedWithReason:NSLocalizedString(@"Please enable Bluetooth then try again.", @"")];
            break;
            
        case CBPeripheralManagerStateUnsupported:
            [self reportFailedWithReason:NSLocalizedString(@"You device does not support this app.", @"")];
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            [self reportFailedWithReason:NSLocalizedString(@"Please authorize this app to use Bluetooth then try again.", @"")];
            break;

        default:
            // other temporary states are ignored
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not start service\nInfo: %@", @""), error.localizedDescription];
        [self reportFailedWithReason:message];
    }
    else {
        [self resumeChatServer];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not start service\nInfo: %@", @""), error.localizedDescription];
        [self reportFailedWithReason:message];
    }
    else {
        [self reportChatServerReady];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
    BOOL hasResponded = NO;
    BOOL hasGotValidMessage = NO;

    for (CBATTRequest *request in requests) {
        
        if (!hasResponded) {
            hasResponded = YES;
            [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        }

        if (request.value) {
            NSString *message = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
            if (message) {
                [[BCMessageManager sharedManager] addMessage:message direction:BCMessageDirectionIncoming];
                hasGotValidMessage = YES;
            }
        }
    }
    
    if (hasGotValidMessage) {
        [self.chatManagerDelegate newMessageDidCome];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    if (characteristic == self.peripheralToCentralCharacteristic) {
        [self.chatServerDelegate chatClientDidCome];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    
    if (characteristic == self.peripheralToCentralCharacteristic) {
        [self.chatManagerDelegate chatRoomDidClose];
    }
}

@end
