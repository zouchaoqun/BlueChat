//
//  BCConstants.h
//  BlueChatLib
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#ifndef BCConstants_h
#define BCConstants_h

#pragma mark - Constants

typedef NS_ENUM(NSInteger, BCConstant) {
    BCConstantMaximumNameLength = 16
};

#pragma mark - BLE UUIDs

/**
 *  UUID of the Chat Server service
 */
extern NSString *const BCChatServiceUUID;

/**
 *  UUID of the Characteristic for central to send messages to the peripheral. Write only.
 */
extern NSString *const BCChatCentralToPeripheralCharacteristicUUID;

/**
 *  UUID of the Characteristic for peripheral to send messages to the central. Indicate and Read.
 */
extern NSString *const BCChatPeripheralToCentralCharacteristicUUID;

/**
 *  UUID of the Characteristic for peripheral to tell the central to disconnect. Indicate and Read.
 */
extern NSString *const BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID;


#endif /* BCConstants_h */
