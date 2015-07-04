//
//  StorageManager.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/*recieve message */
#define MESSAGE_RECIEVED @"MessageReceived"
#define MESSAGE_KEY_FOR_MESSAGE @"message"
#define MESSAGE_CHAT_LOADED @"ChatMessageLoaded"
#define MESSAGE_KEY_FOR_ALL_MESSAGES @"allmessages"

@class Database;
@class Message;
@class Buddy;
@class Chat;

@interface StorageManager : NSObject
{
    Database* _database;
    BOOL _isFreshInstall;
    NSString* _databasePath;
}
+(StorageManager *)sharedInstance;

-(void)saveChat:(Chat*) aChat;
-(void)loadAllChatList:(NSMutableDictionary*) allChats ; //forRosters:(NSDictionary*) allBuddyList;

-(BOOL)updateLastActivity:(Chat*) aChat;
-(BOOL)updateChatName:(Chat*) aChat;

-(void)saveNewRosters:(NSArray*) aRosters;
-(void)saveNewRoster:(Buddy*) aBuddy;
-(void)removeRosters:(NSArray*) aRosters;
-(void)removeRoster:(Buddy*) aBuddy;
-(void)updateRosters:(NSArray*) aRosters;
-(void)updateRosterStatus:(Buddy*) aBuddy;
-(void)updateRosterAvatar:(Buddy*) aBuddy;
-(BOOL) loadAllRosters:(NSMutableDictionary*) aRosterDictionay;

-(NSMutableArray*)getAllChatMessagesForState:(NSInteger) aChatState;
-(void) storeChatMessage:(Message*) aMesage;
-(void) updateChatMessage:(Message*) aMesage;
-(void) loadAllChatMessags:(NSString*) aChatJID;

-(void) loadAllUiChatMessags:(NSMutableArray*) aArray forChatId:(NSString*) aChatJID;

-(void)updateMessageStatus:(NSInteger) aState bareJId:(NSString*)jid messageId:(NSInteger) msgId;

-(BOOL)deleteAllChatMessagesForJid:(NSString *)aChatJID ;

-(BOOL)deleteMessages:(NSMutableArray *)messagesArray;
@end
