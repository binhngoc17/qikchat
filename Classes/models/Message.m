//
//  Message.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "Message.h"
#import "XmppController.h"

@implementation Message


-(id)initWithTextMessage:(NSString *)theMessage withJid:(NSString *)aJid
{
    self = [super init];
    
    if(self)
    {
        self.body = theMessage;
        self.bareJid = aJid;
        self.messageNumber = 0;
        self.messageType = 0;
        self.isOutGoing = YES;
        
        self.date = [NSDate dateWithTimeIntervalSinceNow:0];
      
        self.lresURL = @"";;
        self.hresURL = @"";
        self.fileData   = nil;
        self.messageStatus = MESSAGE_STATUS_UNKNOWN;
    }
    return self;
}

+(Message*)messageWithText:(NSString *)theMessage withJid:(NSString *)aJid
{
    return [[Message alloc] initWithTextMessage:theMessage withJid: aJid ];
}


+(NSString *)getStringMessageType:(MessageType)msgType {
    
    switch (msgType) {
        case TEXT_TYPE_MESSAGE:
            return @"TEXT";
        case AUDIO_TYPE_MESSAGE:
            return @"AUDIO";
            
        case VIDEO_TYPE_MESSAGE:
            return @"VIDEO";
            
        case LOCATION_TYPE_MESSAGE:
            return @"LOCATION";
            
        case IMAGE_TYPE_MESSAGE:
            return @"IMAGE";
            
        default:
            break;
    }
    
    
    return @"";
}

+(MessageType)getMessageType:(NSString*)msgType {
    
    MessageType retType = TEXT_TYPE_MESSAGE;
    if( [msgType isEqualToString:@"IMAGE"] )
    {
        retType = IMAGE_TYPE_MESSAGE;
    }
    else if( [msgType isEqualToString:@"AUDIO"] )
    {
        retType = AUDIO_TYPE_MESSAGE;
    }
    else if( [msgType isEqualToString:@"VIDEO"] )
    {
        retType = VIDEO_TYPE_MESSAGE;
    }
    else if( [msgType isEqualToString:@"LOCATION"] )
    {
        retType = LOCATION_TYPE_MESSAGE;
    }
    
    return retType;
}


@end
