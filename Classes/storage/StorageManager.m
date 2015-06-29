//
//  StorageManager.m
//  ChatNA
//
//  Created by Ram Bhawan Chauhan on 06/09/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//

#import "StorageManager.h"
#import "Database.h"
#import "Storage.h"
#import "SettingsController.h"

#import "Chat.h"
#import "Buddy.h"
#import "Message.h"
#import "Literals.h"
#import "Utility.h"

@implementation StorageManager

#pragma mark - manage context

+(StorageManager *)sharedInstance {
    static StorageManager *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[StorageManager alloc] init];
            
        }
        return sharedSingleton;
    }
}
- (id)init
{
	if ((self = [super init]))
	{
		int error = 0 ;
        _isFreshInstall = NO;
		if ((error = sqlite3_config(SQLITE_CONFIG_SERIALIZED)) != SQLITE_OK)
		{
            NSLog(@"CHATNA SQLLITE ERROR!!!");
        }
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsPath = [paths objectAtIndex:0];
	
         _databasePath = [documentsPath stringByAppendingPathComponent:KCHATNA_DB] ;
        
		_database = [Database databaseWithPath:_databasePath] ;
        
		if (![_database open])
		{
            _isFreshInstall = YES;
			NSLog(@"Could not open db with fmdb.");
		}
        else
        {
            _isFreshInstall = false;
        }
        [self checkDBSchema];
	}
    
	return self;
}

/**
 *
 */
- (void) executeSQLStatements:(NSArray*)sqlStatements
{
	NSUInteger statementsCount = [sqlStatements count];
    
	for (NSUInteger iSQLStatement = 0; iSQLStatement < statementsCount; ++iSQLStatement)
	{
		NSString *sql = [sqlStatements objectAtIndex:iSQLStatement];
		
		DASSERT(sql && [sql length] > 0);
        
		if ([_database executeUpdate:sql, nil])
		{
			NSLog(@"Successfully run SQL statement: '%@'", sql);
		}
		else
		{
            NSLog(@"Failed to run SQL statement: '%@' with error: '%@'", sql, [_database lastErrorMessage]);
		}
	}
}

/**
 *
 */
- (void) executeSQLStatement:(NSString *) sqlStatement
{
	NSArray *sqlStatements = [[NSArray alloc] initWithObjects:sqlStatement, nil];
	
	[self executeSQLStatements:sqlStatements];
    
}

/**
 *
 */
- (void) checkDBSchema
{
	NSString *db_version =  [[SettingsController sharedInstance ] getDatabaseVersion];
    
	if(!db_version || [db_version isEqualToString:KDATABASE_CURRENT_VERSION])
	{
		if(_isFreshInstall)
		{
			[self createDatabase];
            _isFreshInstall = YES;
		}
		else
		{
			[_database close];
			[_database open];
			[self createDatabase];
		}
 	}
    else
    {
        [_database close];
        [self deleteDatabase];
        [_database open];
        [self createDatabase];
    }
}

/**
 *
 */
- (void)deleteDatabase
{
	// deleting the database is in fact nothing more than deleting the database file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL dbExists = [fileManager fileExistsAtPath:_databasePath];
	if (dbExists) {
		[fileManager removeItemAtPath:_databasePath error:NULL];
	}
}

- (void) createDatabase
{
	NSMutableArray *sqlStatements = [[NSMutableArray alloc] init];
    
    NSMutableString *abContacts = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ",KTableContacts];
    [abContacts appendFormat:@"('%@' INTEGER PRIMARY KEY, ", kTableContactFieldLUID];
    [abContacts appendFormat:@"'%@' TEXT NOT NULL, ", kTableContactFieldName];
    [abContacts appendFormat:@"'%@' TEXT NOT NULL)", kTableContactFieldNumbers];
    
    [sqlStatements addObject:abContacts];
    
    
    NSMutableString *rosters = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ",KTableRosters];
    [rosters appendFormat:@"('%@' TEXT PRIMARY KEY NOT NULL, ", kTableRosterFieldJID];
    [rosters appendFormat:@"'%@' TEXT NOT NULL, ", kTableRosterFieldName];
    [rosters appendFormat:@"'%@' TEXT NOT NULL, ", kTableRosterFieldNumber];
    [rosters appendFormat:@"'%@' TEXT NOT NULL, ", kTableRosterFieldStatusText];
    [rosters appendFormat:@"'%@' INTEGER, ", kTableRosterFieldStatus];
    [rosters appendFormat:@"'%@' INTEGER, ", kTableRosterFieldABLUID];
    [rosters appendFormat:@"'%@' TEXT NOT NULL, ", kTableRosterFieldHResURL];
    [rosters appendFormat:@"'%@' BLOB)", kTableRosterFieldAvatar];
    [sqlStatements addObject:rosters];
    
  
    NSMutableString *createChats = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ",KTableChats];
    [createChats appendFormat:@"('%@' TEXT PRIMARY KEY NOT NULL, ", kTableChatFieldJID];
    [createChats appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatFieldDisplaName];
    [createChats appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatFieldLastMsg];
    [createChats appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatFieldLastTime];
    [createChats appendFormat:@"'%@' INTEGER, ", kTableChatFieldLastMsgId];
    [createChats appendFormat:@"'%@' INTEGER)", kTableChatFieldUnreadCount];
    [sqlStatements addObject:createChats];
   
    
    NSMutableString *chatItems = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ",KTableChatItems];
    [chatItems appendFormat:@"('%@' INTEGER, ", kTableChatItemID];
    [chatItems appendFormat:@"'%@' INTEGER, ", kTableChatItemType];
    [chatItems appendFormat:@"'%@' INTEGER, ", kTableChatItemIsOutGoing];
    [chatItems appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatItemChatJID];
    [chatItems appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatItemTimestamp];
    [chatItems appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatItemChatBody];
    [chatItems appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatItemLResURL];
    [chatItems appendFormat:@"'%@' TEXT NOT NULL, ", kTableChatItemHResURL];
    [chatItems appendFormat:@"'%@' BLOB, ", kTableChatItemFileData];
    [chatItems appendFormat:@"'%@' INTEGER)", kTableChatItemState];
    
    [sqlStatements addObject:chatItems];
    
    
    NSMutableString *blockUsers = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ",kTableBlockUser];
    [blockUsers appendFormat:@"('%@' TEXT PRIMARY KEY NOT NULL)", kTableBlockFieldChatJID];
    [sqlStatements addObject:blockUsers];
   
    
    [self executeSQLStatements:sqlStatements];
    
    [[SettingsController sharedInstance] setDatabaseVersion:KDATABASE_CURRENT_VERSION];
    
}

-(void)blockUserWithJid:(NSString *)blockUserjid {
    // Add Entry to PhoneBook Data base and reset all fields
    
    [_database beginDeferredTransaction];
    
    NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
    
    [statement appendFormat:@"INSERT OR REPLACE INTO %@ (",kTableBlockUser];
    [statement appendFormat:@"%@)",kTableBlockFieldChatJID];
    [statement appendString:@" VALUES (?)"];
    
    NSMutableArray*     args        = [ [NSMutableArray alloc] initWithObjects:blockUserjid,nil ];
    
    BOOL success = [_database executeUpdate:statement withArgumentsInArray:args];
    
    if (!success) {
        NSLog(@" Error on saving chat %@",[_database lastErrorMessage]);
        goto rollback;
    }
    
rollback:
    
    if(success)
    {
        [_database commit];
    }
    else
    {
        [_database rollback];
        DASSERT("error");
    }

}


-(NSArray*)getAllBlockedUser
{
    
    NSMutableArray* ret = [[NSMutableArray alloc] init] ;
    
    NSMutableString* statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
    [statement appendFormat:@"SELECT * FROM %@ ", kTableBlockUser];
    
    ResultSet *rs = [_database executeQuery:statement];
    while ([rs next]) {
        
        NSMutableDictionary* row = [NSMutableDictionary dictionary];
        
        [row setObject:[rs stringForColumn:kTableBlockFieldChatJID] forKey:kTableBlockFieldChatJID];
        
        [ret addObject:row];
    }
    return ret;

}


-(void)saveChat:(Chat*) aChat {
    // Add Entry to PhoneBook Data base and reset all fields
    
    [_database beginDeferredTransaction];
    
    NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
    
    [statement appendFormat:@"INSERT OR REPLACE INTO %@ (",KTableChats];
    [statement appendFormat:@"%@, ",kTableChatFieldJID];
    [statement appendFormat:@"%@, ",kTableChatFieldDisplaName];
    [statement appendFormat:@"%@, ",kTableChatFieldLastMsg];
    [statement appendFormat:@"%@, ",kTableChatFieldLastTime];
    [statement appendFormat:@"%@, ",kTableChatFieldLastMsgId];
    [statement appendFormat:@"%@)",kTableChatFieldUnreadCount];
    
    [statement appendString:@" VALUES (?,?,?,?,?,?)"];
    
    NSString* lastdate = [Utility dateToString:[aChat lastActivityDate] withFormat:kChatTimestampFormat];
    
    NSMutableArray*     args        = [ [NSMutableArray alloc] initWithObjects:
                                       [aChat chatBareJid],
                                       [aChat getDisplayName],
                                       [aChat lastMessage ],
                                       lastdate,
                                       [NSNumber numberWithInt:[aChat lastMessageId]],
                                       [NSNumber numberWithInt:[aChat unreadCount] ],
                                        nil ];
    
    BOOL success = [_database executeUpdate:statement withArgumentsInArray:args];
    
    if (!success) {
        NSLog(@" Error on saving chat %@",[_database lastErrorMessage]);
        goto rollback;
    }
    
rollback:
    
    if(success)
    {
        [_database commit];
    }
    else
    {
        [_database rollback];
        DASSERT("error");
    }

}

-(BOOL)updateLastActivity:(Chat*) aChat
{
    NSString* lastDate = [Utility dateToString:[aChat lastActivityDate] withFormat:kChatTimestampFormat];
    NSString*   statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@ ='%@', %@=%d, %@=%d WHERE %@ = '%@'", KTableChats,kTableChatFieldLastMsg,[aChat lastMessage],kTableChatFieldLastTime, lastDate ,kTableChatFieldLastMsgId, [aChat lastMessageId], kTableChatFieldUnreadCount, [aChat unreadCount], kTableChatFieldJID,[aChat chatBareJid]];
    
    BOOL success =  [_database executeUpdate:statement];
    
    return success;
}

-(BOOL)updateChatName:(Chat*) aChat {
    NSString*   statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@'", KTableChats,kTableChatFieldDisplaName,[aChat getDisplayName],kTableChatFieldJID,[aChat chatBareJid]];
    
    return [_database executeUpdate:statement];
}

-(void)loadAllChatList:(NSMutableDictionary*) allChats //forRosters:(NSDictionary*) allBuddyList;
{
    NSMutableString* statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
    [statement appendFormat:@"SELECT * FROM %@ ORDER BY lasttime DESC", KTableChats];
  
    ResultSet *rs = [_database executeQuery:statement];
    while ([rs next]) {
        
        NSString* jid = [rs stringForColumn:kTableChatFieldJID];
        NSString* name = [rs stringForColumn:kTableChatFieldDisplaName];
        NSString* lastMsg = [rs stringForColumn:kTableChatFieldLastMsg];
        NSString* lasttime = [rs stringForColumn:kTableChatFieldLastTime];
        NSInteger msgNumber = [rs intForColumn:kTableChatFieldLastMsgId];
        NSInteger unreadCount = [rs intForColumn:kTableChatFieldUnreadCount];
        
        Chat* chat = [[Chat alloc ] initWithChatJID:jid withName:name];
        [chat setLastMessage:lastMsg withTime:lasttime withUnread:unreadCount messageId:msgNumber];
        
        /*if( allBuddyList )
        {
            Buddy* associatedBuddy = [allBuddyList objectForKey:jid];
            if( associatedBuddy ){
                UIImage* avatar = [associatedBuddy avatarImage];
                [chat setChatImage:avatar];
                [chat setChatDisplayName:associatedBuddy.getDisplayName];
            }
        }*/
        
        [allChats setObject:chat forKey:jid];
    }
}


////////////////////////////////////////////////

-(void)saveNewRosters:(NSArray*) aRosters
{
    if( [aRosters count] == 0 )
        return;
    
    [_database beginDeferredTransaction];
    
    BOOL success = NO;
    
    for (NSInteger i=[aRosters count]-1; i>=0; i--)
    {
        Buddy* buddy = [aRosters objectAtIndex:i];
        
        NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
        
        [statement appendFormat:@"INSERT OR REPLACE INTO %@ (",KTableRosters];
        [statement appendFormat:@"%@, ",kTableRosterFieldJID];
        [statement appendFormat:@"%@, ",kTableRosterFieldName];
        [statement appendFormat:@"%@, ",kTableRosterFieldNumber];
        [statement appendFormat:@"%@, ",kTableRosterFieldStatusText];
        [statement appendFormat:@"%@, ",kTableRosterFieldStatus];
        [statement appendFormat:@"%@, ",kTableRosterFieldABLUID];
        [statement appendFormat:@"%@, ",kTableRosterFieldHResURL];
        [statement appendFormat:@"%@)",kTableRosterFieldAvatar];
        
        [statement appendString:@" VALUES (?,?,?,?,?,?,?,?)"];
        
     
        NSNumber* status = [NSNumber numberWithInteger:(NSInteger)[buddy getStatus]];
        NSNumber* luid = [NSNumber numberWithInteger:(NSInteger)[buddy getABLUID]];
        
        NSString* phone = [buddy getPhoneNumer];
        
        NSString* statusText = [buddy getCurrentStatusText];
        
        NSData* avatarData =  UIImagePNGRepresentation(buddy.avatarImage);
        
        NSMutableArray*     args        = [ [NSMutableArray alloc] initWithObjects:
                                           buddy.accountName,
                                           [buddy getDisplayName],
                                           phone,
                                           statusText,
                                            status,
                                           luid,
                                           buddy.hresAvtarURL,
                                           avatarData?avatarData:[NSNull null],
                                           nil ];
        
        success = [_database executeUpdate:statement withArgumentsInArray:args];
        
        if (!success) {
            NSLog(@" Error on saving chat %@",[_database lastErrorMessage]);
            goto rollback;
        }
    }
    
rollback:
    
    if(success)
    {
        [_database commit];
    }
    else
    {
        [_database rollback];
        DASSERT("error");
    }
    
}
-(void)saveNewRoster:(Buddy*) aBuddy
{
    if( !aBuddy)
        return;
    
    [_database beginDeferredTransaction];
    
    BOOL success = NO;
    
    NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
        
    [statement appendFormat:@"INSERT OR REPLACE INTO %@ (",KTableRosters];
    [statement appendFormat:@"%@, ",kTableRosterFieldJID];
    [statement appendFormat:@"%@, ",kTableRosterFieldName];
    [statement appendFormat:@"%@, ",kTableRosterFieldNumber];
    [statement appendFormat:@"%@, ",kTableRosterFieldStatusText];
    [statement appendFormat:@"%@, ",kTableRosterFieldStatus];
    [statement appendFormat:@"%@, ",kTableRosterFieldABLUID];
    [statement appendFormat:@"%@, ",kTableRosterFieldHResURL];
    [statement appendFormat:@"%@)",kTableRosterFieldAvatar];
    
    [statement appendString:@" VALUES (?,?,?,?,?,?,?,?)"];
    
    
    NSNumber* status = [NSNumber numberWithInteger:(NSInteger)[aBuddy getStatus]];
    NSNumber* luid = [NSNumber numberWithInteger:(NSInteger)[aBuddy getABLUID]];
    
    NSString* phone = [aBuddy getPhoneNumer];
    NSString* statusText = [aBuddy getCurrentStatusText];
    
    NSData* avatarData =  UIImagePNGRepresentation(aBuddy.avatarImage);
    
    NSMutableArray*     args        = [ [NSMutableArray alloc] initWithObjects:
                                       aBuddy.accountName,
                                       [aBuddy getDisplayName],
                                       phone,
                                       statusText,
                                       status,
                                       luid,
                                       aBuddy.hresAvtarURL,
                                       avatarData?avatarData:[NSNull null],
                                       nil ];
    
    success = [_database executeUpdate:statement withArgumentsInArray:args];
    
    if (!success) {
            NSLog(@" Error on saving chat %@",[_database lastErrorMessage]);
            goto rollback;
    }
    
rollback:
    
    if(success)
    {
        [_database commit];
    }
    else
    {
        [_database rollback];
        DASSERT("error");
    }
    
}

-(void)removeRosters:(NSArray*) aRosters
{
    for (NSInteger i=0; i<[aRosters count]; i++)
    {
        Buddy* buddy = [aRosters objectAtIndex:i];
        [self removeRoster:buddy];
    }
}

-(void)removeRoster:(Buddy*) aBuddy
{
    if( !aBuddy )
        return;
    
     NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
    [statement appendFormat:@"DELETE FROM %@ WHERE %@ ='%@'",KTableRosters,kTableRosterFieldJID, aBuddy.accountName ];
    [_database executeUpdate:statement];
    
}

-(void)updateRosters:(NSArray*) aRosters
{
    for (NSInteger i=0; i<[aRosters count]; i++)
    {
        Buddy* buddy = [aRosters objectAtIndex:i];
        [self updateRosterAvatar:buddy];
    }
}

-(void)updateRosterStatus:(Buddy*) aBuddy
{
    if( !aBuddy )
        return;
    
    NSString* stext = [aBuddy getCurrentStatusText];
    NSString* jid = aBuddy.accountName;
    if( [stext length]  && [jid length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ ='%@'", KTableRosters, kTableRosterFieldStatusText, stext, kTableRosterFieldJID ,jid ];
        if( statement )
        [_database executeUpdate:statement];
    }
}

-(void)updateRosterAvatar:(Buddy*) aBuddy
{
    if( !aBuddy )
        return;
    
    NSString* jid = aBuddy.accountName;
    
    NSData* avatarData =  UIImagePNGRepresentation(aBuddy.avatarImage);
   
    NSString* displayName = [aBuddy getDisplayName];
    
    if( [avatarData length]  && [aBuddy.hresAvtarURL length] && [displayName length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@', %@=?, %@='%@' WHERE %@ ='%@'", KTableRosters, kTableRosterFieldHResURL, aBuddy.hresAvtarURL , kTableRosterFieldAvatar, kTableRosterFieldName ,displayName, kTableRosterFieldJID ,jid ];
        [_database executeUpdate:statement,avatarData];
    }
    else if( [avatarData length] && [displayName length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@=?, %@='%@' WHERE %@ ='%@'", KTableRosters,  kTableRosterFieldAvatar, kTableRosterFieldName ,displayName, kTableRosterFieldJID ,jid ];
        [_database executeUpdate:statement,avatarData];
    }
    else if( [aBuddy.hresAvtarURL length] && [displayName length]  )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@', %@='%@' WHERE %@ ='%@'", KTableRosters,  kTableRosterFieldHResURL, aBuddy.hresAvtarURL, kTableRosterFieldName ,displayName, kTableRosterFieldJID ,jid ];
        [_database executeUpdate:statement];
    }
    else if( [avatarData length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@=? WHERE %@ ='%@'", KTableRosters, kTableRosterFieldAvatar, kTableRosterFieldJID ,jid ];
        [_database executeUpdate:statement,avatarData];
        [_database executeUpdate:statement];
    }
    else if( [displayName length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@ ='%@'", KTableRosters, kTableRosterFieldName, displayName, kTableRosterFieldJID ,jid ];
        [_database executeUpdate:statement];
    }
}

-(BOOL)loadAllRosters:(NSMutableDictionary*) aRosterDictionay
{
    NSMutableString* statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
    [statement appendFormat:@"SELECT * FROM %@", KTableRosters];
    
    ResultSet *rs = [_database executeQuery:statement];
    while ([rs next])
    {
      	NSString * jid          = [rs stringForColumnIndex:0];
		NSString *name          = [rs stringForColumnIndex:1];
     	NSString * number       = [rs stringForColumnIndex:2];
		NSString * stext        = [rs stringForColumnIndex:3];
		int  status             = [rs intForColumnIndex:4];
		int uid                 = [rs intForColumnIndex:5];
        NSString *hresURL       = [rs stringForColumnIndex:6];
		NSData * avatarData     = [rs dataForColumnIndex:7];
		
        Buddy* buddy = [Buddy buddyWithDisplayName:name accountName:jid status:(OTRBuddyStatus)status groupName:@"" ];
                        
        [buddy setCurrentStatusText:stext];
        [buddy setCurrentStatus:(OTRBuddyStatus)status];
        
        [buddy setPhoneNumber:number];
        [buddy setABLUID:uid];
         buddy.hresAvtarURL = hresURL;
        [buddy setAvatarImage:[UIImage imageWithData:avatarData]];
        
        [aRosterDictionay setObject:buddy forKey:jid];
        
    }
    
    return YES;
}


-(void)storeChatMessage:(Message*) aMesage
{
    if( aMesage == nil )
        return;
    
    [_database beginDeferredTransaction];
    
    BOOL success = NO;
    
    NSMutableString*    statement   = [[NSMutableString alloc] initWithString:kEmptyString] ;
        
    NSData* fileData  = aMesage.fileData;
    
    [statement appendFormat:@"INSERT OR REPLACE INTO %@ (",KTableChatItems];
    [statement appendFormat:@"%@, ",kTableChatItemID];
    [statement appendFormat:@"%@, ",kTableChatItemType];
    [statement appendFormat:@"%@, ",kTableChatItemIsOutGoing];
    [statement appendFormat:@"%@, ",kTableChatItemChatJID];
    [statement appendFormat:@"%@, ",kTableChatItemTimestamp];
    [statement appendFormat:@"%@, ",kTableChatItemChatBody];
    [statement appendFormat:@"%@, ",kTableChatItemLResURL];
    [statement appendFormat:@"%@, ",kTableChatItemHResURL];
    [statement appendFormat:@"%@, ",kTableChatItemFileData];
    [statement appendFormat:@"%@)",kTableChatItemState];
    
    [statement appendString:@" VALUES (?,?,?,?,?,?,?,?,?,?)"];
    
    NSString* timeStampStr = [Utility dateToString:aMesage.date withFormat:kChatTimestampFormat];
        
    NSMutableArray*     args        = [ [NSMutableArray alloc] initWithObjects:
                                           [NSNumber numberWithInt:aMesage.messageNumber],
                                           [NSNumber numberWithInt:aMesage.messageType],
                                           [NSNumber numberWithInt:aMesage.isOutGoing],
                                           aMesage.bareJid,
                                           timeStampStr,
                                           aMesage.body,
                                           aMesage.lresURL,
                                           aMesage.hresURL,
                                           fileData?fileData:[NSNull null],
                                           [NSNumber numberWithInt:aMesage.messageStatus],
                                            nil ];
        
    success = [_database executeUpdate:statement withArgumentsInArray:args];
        
    if (!success) {
        NSLog(@" Error on saving chat %@",[_database lastErrorMessage]);
        goto rollback;
    }
    
rollback:
    
    if(success)
    {
        [_database commit];
    }
    else
    {
        [_database rollback];
        DASSERT("error");
    }
    
}

-(void)updateChatMessage:(Message*) aMesage
{
    if( aMesage == nil )
        return;
 
    MessageStatus state = aMesage.messageStatus;
    NSString* jid = aMesage.bareJid;
    if( state>0  && [jid length] && aMesage.messageNumber && [aMesage.hresURL length] )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d, %@ = '%@', %@='%@' WHERE %@ ='%@' AND %@ = %d", KTableChatItems, kTableChatItemState, state, kTableChatItemLResURL, aMesage.lresURL, kTableChatItemHResURL, aMesage.hresURL, kTableChatItemChatJID ,jid , kTableChatItemID, aMesage.messageNumber ];
        if( statement )
            [_database executeUpdate:statement];
    }
    else if( state>0  && [jid length] && aMesage.messageNumber )
    {
            NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ ='%@' AND %@ = %d", KTableChatItems, kTableChatItemState, state, kTableChatItemChatJID ,jid , kTableChatItemID, aMesage.messageNumber ];
            if( statement )
                [_database executeUpdate:statement];
    }
}

-(void) updateMessageStatus:(NSInteger) aState bareJId:(NSString*)jid messageId:(NSInteger) msgId
{
    if( aState>0  && [jid length] && msgId )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ ='%@' AND %@ = %d", KTableChatItems, kTableChatItemState, aState, kTableChatItemChatJID ,jid , kTableChatItemID, msgId ];
        if( statement )
            [_database executeUpdate:statement];
    }
    else if( aState>0  && [jid length] && msgId <=0 )
    {
        NSString* statement   = [NSString stringWithFormat:@"UPDATE %@ SET %@ = %d WHERE %@ ='%@' AND %@ = %d AND %@ = %d", KTableChatItems, kTableChatItemState, aState, kTableChatItemChatJID ,jid , kTableChatItemIsOutGoing, YES, kTableChatItemState , MESSAGE_STATUS_USER ];
        if( statement )
            [_database executeUpdate:statement];
    }
}

-(NSMutableArray*)getAllChatMessagesForState:(NSInteger) aChatState
{
    NSMutableArray* retArray = [[NSMutableArray alloc] init] ;
    
    NSMutableString* statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
    [statement appendFormat:@"SELECT * FROM %@ WHERE %@ = %d AND %@ =%d", KTableChatItems, kTableChatItemState, aChatState ,kTableChatItemIsOutGoing, YES ];
    
    ResultSet *rs = [_database executeQuery:statement];
    
    while ([rs next])
    {
      	NSInteger id            = [rs intForColumnIndex:0];
		NSInteger type          = [rs intForColumnIndex:1];
        NSInteger isOutGoing    = [rs intForColumnIndex:2];
        
        NSString* chatJid       = [rs stringForColumnIndex:3];
        NSString* time          = [rs stringForColumnIndex:4];
        NSString* body          = [rs stringForColumnIndex:5];
        NSString* lresUrl       = [rs stringForColumnIndex:6];
        NSString* hresUrl       = [rs stringForColumnIndex:7];
        
        NSData* fileData   = [rs dataForColumnIndex:8];
        NSInteger state    = [rs intForColumnIndex:9];
        
	    
        Message* msg = [ [Message alloc] initWithTextMessage:body withJid:chatJid];
     
        msg.messageNumber = id;
        msg.messageType = type;
        msg.isOutGoing = isOutGoing;
        msg.date = [Utility stringToDate:time withFormat:kChatTimestampFormat];
        msg.lresURL = lresUrl;
        msg.hresURL = hresUrl;
        
        msg.fileData   =  fileData;
        msg.messageStatus = state;
      
        [retArray addObject:msg];
    }
    return retArray;
    
}


-(BOOL)deleteAllChatMessagesForJid:(NSString *)aChatJID {
    
    NSMutableString *statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
     [statement appendFormat:@"DELETE FROM %@ WHERE %@ ='%@'", KTableChatItems, kTableChatItemChatJID, aChatJID ];
    
   BOOL sucess = [_database executeUpdate:statement];
    
   statement = [[NSMutableString alloc] initWithString:kEmptyString];
   [ statement appendFormat:@"DELETE FROM %@ WHERE %@ = '%@'",KTableChats,kTableChatFieldJID,aChatJID];
    
    sucess = sucess && [_database executeUpdate:statement];
    
    return sucess;
    
}


-(void) loadAllChatMessags:(NSString*) aChatJID
{
    NSMutableString* statement = [[NSMutableString alloc] initWithString:kEmptyString];
    
    [statement appendFormat:@"SELECT * FROM %@ WHERE %@ ='%@'", KTableChatItems, kTableChatItemChatJID, aChatJID ];
    
    ResultSet *rs = [_database executeQuery:statement];
    
    while ([rs next])
    {
      	NSInteger id            = [rs intForColumnIndex:0];
		NSInteger type          = [rs intForColumnIndex:1];
        NSInteger isOutGoing    = [rs intForColumnIndex:2];
        
        NSString* chatJid       = [rs stringForColumnIndex:3];
        NSString* time          = [rs stringForColumnIndex:4];
        NSString* body          = [rs stringForColumnIndex:5];
        NSString* lresUrl       = [rs stringForColumnIndex:6];
        NSString* hresUrl       = [rs stringForColumnIndex:7];
        
        NSData* fileData   = [rs dataForColumnIndex:8];
        NSInteger state    = [rs intForColumnIndex:9];
	    
        Message* msg = [ [Message alloc] initWithTextMessage:body withJid:chatJid];
        
        msg.messageNumber = id;
        msg.messageType = type;
        msg.isOutGoing = isOutGoing;
        msg.date = [Utility stringToDate:time withFormat:kChatTimestampFormat];
        msg.lresURL = lresUrl;
        msg.hresURL = hresUrl;
        
        msg.fileData   =  fileData;
        msg.messageStatus = state;
        
        NSDictionary *messageInfo = [NSDictionary dictionaryWithObject:msg forKey:MESSAGE_KEY_FOR_MESSAGE];
        //save it to db and show to user on chat list and chat screen
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_CHAT_LOADED object:self userInfo:messageInfo];
    }
    
}

//not tested Yet-- babul
-(BOOL)deleteMessages:(NSMutableArray *)messagesArray {
    NSMutableString *statement =  [[NSMutableString alloc] initWithString:kEmptyString];
    [statement appendFormat:@"DELETE FROM %@ WHERE %@ in (",KTableChatItems,kTableChatItemID];
    
    for (Message *msg in messagesArray) {
        [statement appendFormat:@"%d,",msg.messageNumber];
    }
    NSString *query = [statement substringToIndex:(statement.length-1)];
    query = [NSString stringWithFormat:@"%@)",query];
    Message *msg = messagesArray[0];
   
    query = [NSString stringWithFormat:@"%@ AND %@ = '%@'",query,kTableChatFieldJID,msg.bareJid];
    
    BOOL value = [_database executeUpdate:query];
    return value;
    
}


@end
