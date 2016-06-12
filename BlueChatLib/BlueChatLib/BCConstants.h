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
    /**
     *  The maximum length of the chat server name. There is a length limit because of the limited space in the BLE advertisement.
     */
    BCConstantMaximumNameLength = 16
};

#pragma mark - BLE UUIDs

/**
 *  UUID of the Chat Server service
 */
extern NSString *const BCChatServiceUUID;

/**
 *  UUID of the Characteristic for central to send messages to the peripheral. Write only. The data is UTF8 encoded text.
 */
extern NSString *const BCChatCentralToPeripheralCharacteristicUUID;

/**
 *  UUID of the Characteristic for peripheral to send messages to the central. Indicate and Read. The data is UTF8 encoded text.
 */
extern NSString *const BCChatPeripheralToCentralCharacteristicUUID;

/**
 *  UUID of the Characteristic for peripheral to tell the central to disconnect. Indicate and Read. The data is one-byte integer and the value is not checked by the central.
 */
extern NSString *const BCChatPeripheralToCentralDisconnectRequestCharacteristicUUID;


#endif /* BCConstants_h */
