//
//  MessageController.h
//  ChatNA
//
//  Created by Ram Bhawan Chauhan on 13/08/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "XMPPStream.h"
#import "XMPPFramework.h"
#import "XMPPRoom.h"
#import "XMPPMessage.h"
#import "XMPPRoomOccupant.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
@class Message;
@class Buddy;
@class Chat;
@class FileUploadResponse;

@interface MessageController : NSObject
{
    XMPPStream *_xmppStream;
    NSMutableDictionary* _allChatList;
    BOOL _isMessageSending;
    NSMutableArray* _allWaitingMessageQueue;
    NSMutableDictionary* _allPendingFileUpload; //queue for file sending
    
}

-(id) initWithStream:(XMPPStream*) xmppStream;
- (void) setup;
- (void)teardown;

-(void) handleServiceAuthenticated;

-(void) handleFileUploadResponse:(FileUploadResponse*) aFileRespone error:(int) error;

/*
 *@author - Ram Chauhan
 * call this method to send message
 * message are queued if offline here
 */
-(void)sendOrQueueChatMessage:(Message *)message;

/*
 *@author - Babul Prabhakar
 * call this method to send Chat Stat
 */
-(NSArray*) getAllChatList;
-(void) updateChatInfoIfExists:(Buddy*) aBuddy;

-(Chat*) getChatForJID:(NSString*) Jid;
-(Chat*) createChatForJID:(NSString*) Jid withDisplayName:(NSString*) aName;
-(void)sendChatState:(int)chatState toJId:(NSString*) toJid;
-(NSInteger) getAllUnreadCounts;

-(void)removeChat:(NSString *)jid ; //created by Babul For Remove option in chat list Screen
-(void)sendorQueueForwardMessages:(Message *)message;

@end

