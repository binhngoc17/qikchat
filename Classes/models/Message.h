//
//  Message.h
//  ChatNa
//
//  Created by Babul Prabhakar on 26/07/14.
//  Copyright (c) 2014 Babul Prabhakar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

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

@end
