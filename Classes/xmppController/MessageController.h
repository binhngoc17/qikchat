//
//  MessageController.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "XMPPFramework.h"
#import "Buddy.h"

#define UPDATE_CHAT_LIST  @"chatpdateNotification"

@class Message;
@class Buddy;
@class Chat;

@interface MessageController : NSObject
{
    XMPPStream *_xmppStream;
    NSMutableDictionary* _allChatList;
   
    BOOL _isMessageSending;
    NSMutableArray* _allWaitingMessageQueue;
}

-(id) initWithStream:(XMPPStream*) xmppStream;
- (void) setup;
- (void)teardown;

-(void) handleServiceAuthenticated;

/*
 *@author - Ram Chauhan
 * call this method to send message
 * message are queued if offline here
 */
-(void)sendOrQueueChatMessage:(Message *)message;

/*
*@author - Ram Chauhan
 * call this method to send Chat Stat
 */
-(NSArray*) getAllChatList;

-(Chat*) chatForIndex:(NSInteger) aIndex;
-(NSInteger) chatCount;

-(Chat*) getChatForJID:(NSString*) Jid;
-(Chat*) createChatForJID:(NSString*) Jid withDisplayName:(NSString*) aName;
-(NSInteger) getAllUnreadCounts;
-(void)removeChat:(NSString *)jid ; 

@end

