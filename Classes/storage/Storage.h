//
//  Storage.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

#define KCHAT_DB                       @"QikAChat.db"
#define kEmptyString                   @""

#define kTableBlockUser                 @"blocked_users"
#define kTableBlockFieldID              @"id"
#define kTableBlockFieldChatJID         @"barejid"

#define KTableChats                    @"chats"
#define kTableChatFieldJID             @"chatjid"
#define kTableChatFieldDisplaName      @"dispname"
#define kTableChatFieldLastMsg         @"lastmsg"
#define kTableChatFieldLastTime        @"lasttime"
#define kTableChatFieldLastMsgId       @"lastmsgid"
#define kTableChatFieldUnreadCount     @"unreadmsg"

#define KTableChatItems                @"chatItems"
#define kTableChatItemID               @"id"
#define kTableChatItemType             @"type"
#define kTableChatItemIsOutGoing       @"issent"
#define kTableChatItemChatJID          @"chatjid"
#define kTableChatItemTimestamp        @"time"
#define kTableChatItemChatBody         @"body"
#define kTableChatItemLResURL          @"lresurl"
#define kTableChatItemHResURL          @"hresurl"
#define kTableChatItemFileData         @"filedata"
#define kTableChatItemState            @"state"


#define KTableContacts                 @"contacts"
#define kTableContactFieldLUID         @"cluid"
#define kTableContactFieldName         @"cname"
#define kTableContactFieldNumbers      @"cnumbers"

#define KTableRosters                 @"rosters"
#define kTableRosterFieldJID          @"jid"
#define kTableRosterFieldName         @"dispname"
#define kTableRosterFieldNumber       @"number"
#define kTableRosterFieldStatusText   @"stext"
#define kTableRosterFieldStatus       @"status"
#define kTableRosterFieldABLUID       @"abluid"
#define kTableRosterFieldHResURL      @"hresurl"
#define kTableRosterFieldAvatar       @"avatar"

@end
