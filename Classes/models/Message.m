//
//  Message.m
//  ChatNa
//
//  Created by Babul Prabhakar on 26/07/14.
//  Copyright (c) 2014 Babul Prabhakar. All rights reserved.
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

@end
