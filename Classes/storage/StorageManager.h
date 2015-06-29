//
//  StorageManager.h
//  ChatNA
//
//  Created by Ram Bhawan Chauhan on 06/09/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@class Chat;
@class Database;
@class ABContact;
@class Message;
@class Buddy;

@interface StorageManager : NSObject
{
    Database* _database;
    BOOL _isFreshInstall;
    NSString* _databasePath;
}
+(StorageManager *)sharedInstance;

-(void)blockUserWithJid:(NSString *)blockUserjid;
-(NSArray*)getAllBlockedUser;

-(void)saveChat:(Chat*) aChat;
-(void)loadAllChatList:(NSMutableDictionary*) allChats forRosters:(NSDictionary*) allBuddyList;

-(BOOL)updateLastActivity:(Chat*) aChat;
-(BOOL)updateChatName:(Chat*) aChat;

-(void)saveABContacts:(NSArray*) aContacts;
-(void)updateABContacts:(NSArray*) aContacts;
-(void)removeABContacts:(NSArray*) aContacts;
-(NSArray*) getAllPBContacts;

-(void)saveNewRosters:(NSArray*) aRosters;
-(void)saveNewRoster:(Buddy*) aBuddy;
-(void)removeRosters:(NSArray*) aRosters;
-(void)removeRoster:(Buddy*) aBuddy;
-(void)updateRosters:(NSArray*) aRosters;
-(void)updateRosterStatus:(Buddy*) aBuddy;
-(void)updateRosterAvatar:(Buddy*) aBuddy;
-(NSArray*) loadAllRosters;

-(NSMutableArray*)getAllChatMessagesForState:(NSInteger) aChatState;
-(void) storeChatMessage:(Message*) aMesage;
-(void) updateChatMessage:(Message*) aMesage;
-(void) loadAllChatMessags:(NSString*) aChatJID;

-(void)updateMessageStatus:(NSInteger) aState bareJId:(NSString*)jid messageId:(NSInteger) msgId;

//created by babul for message deletion
-(BOOL)deleteAllChatMessagesForJid:(NSString *)aChatJID ;

//send only Messages Array;
-(BOOL)deleteMessages:(NSMutableArray *)messagesArray;
@end
