//
//  Message.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Literals.h"

//MessageStatus
enum {
    MESSAGE_STATUS_UNKNOWN, // for recieved message or unknown 0
    MESSAGE_STATUS_WAITING, // local waiting or queued 1
    MESSAGE_STATUS_SERVER, // sent to server 2
    MESSAGE_STATUS_USER,   // recieved by user 3
    MESSAGE_STATUS_READ,   // read by user 4
    MESSAGE_STATUS_FAILED  // failed to send 5
};
typedef NSInteger MessageStatus;

//MEssage Types
enum {
    TEXT_TYPE_MESSAGE,
    LOCATION_TYPE_MESSAGE,
    VIDEO_TYPE_MESSAGE,
    AUDIO_TYPE_MESSAGE,
    IMAGE_TYPE_MESSAGE,
};
typedef NSInteger MessageType;


@interface Message : NSObject

@property (nonatomic, retain) NSString *body;
@property (nonatomic,retain) NSString* bareJid; // always to whom communicating
@property (nonatomic)MessageType messageType;

@property (nonatomic,strong)NSString *lresURL;
@property (nonatomic,strong)NSString *hresURL;
@property (nonatomic,strong)NSString *size;

@property (nonatomic, retain) NSData* fileData;
@property (nonatomic,strong) NSString *extension;

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isOutGoing;
@property (nonatomic) NSInteger messageNumber;

@property (nonatomic)MessageStatus messageStatus;

-(id)initWithTextMessage:(NSString *)message withJid:(NSString*) aJid;

+(Message*)messageWithText:(NSString *)message withJid:(NSString*) aJid;

+(NSString *)getStringMessageType:(MessageType)msgType ;

+(MessageType)getMessageType:(NSString*)msgType ;

@end
