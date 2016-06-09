//
//  BCChatServer.m
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "BCChatServer.h"
#import "BCConstants.h"

@interface BCChatServer () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@property (strong, nonatomic) CBMutableService *chatService;

@property (strong, nonatomic) CBMutableCharacteristic *centralToPeripheralCharacteristic;

@property (strong, nonatomic) CBMutableCharacteristic *peripheralToCentralCharacteristic;

@property (copy, nonatomic) NSString *serverName;

@property (weak, nonatomic) id<BCChatServerDelegate> delegate;

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

- (void)startChatServerWithName:(NSString *)name delegate:(id<BCChatServerDelegate> _Nonnull)delegate {
    
    self.delegate = delegate;
    if (name.length <= BCConstantMaximumNameLength) {
        self.serverName = name;
    }
    else {
        self.serverName = [name substringToIndex:BCConstantMaximumNameLength];
    }
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)stopChatServier {
    
    [self.peripheralManager stopAdvertising];
}

#pragma mark - Helpers
- (void)setupServiceCharacteristics {
    
    self.chatService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:BCChatServiceUUID] primary:YES];
    
    self.centralToPeripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BCChatCentralToPeripheralCharacteristicUUID] properties:CBCharacteristicPropertyWrite value:nil permissions:0];

    self.peripheralToCentralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:BCChatPeripheralToCentralCharacteristicUUID] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyIndicate value:nil permissions:0];

    self.chatService.characteristics = @[self.centralToPeripheralCharacteristic, self.peripheralToCentralCharacteristic];
    
    [self.peripheralManager addService:self.chatService];
}

- (void)reportStartFailedWithReason:(NSString *)reason {
    
    [self.delegate chatServerDidFailToStart:reason];
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager {

    switch (peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupServiceCharacteristics];
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            [self reportStartFailedWithReason:NSLocalizedString(@"Please enable Bluetooth then try again.", @"")];
            break;
            
        case CBPeripheralManagerStateUnsupported:
            [self reportStartFailedWithReason:NSLocalizedString(@"You device does not support this app.", @"")];
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            [self reportStartFailedWithReason:NSLocalizedString(@"Please authorize this app to use Bluetooth then try again.", @"")];
            break;

        default:
            // other temporary states are ignored
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not start service\nInfo: %@", @""), error.localizedDescription];
        [self reportStartFailedWithReason:message];
    }
    else {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[self.chatService.UUID], CBAdvertisementDataLocalNameKey : self.serverName}];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    if (error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Could not start service\nInfo: %@", @""), error.localizedDescription];
        [self reportStartFailedWithReason:message];
    }
    else {
        [self.delegate chatServerDidStart];
    }
}

@end
