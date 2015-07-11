//
//  Chat.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Message.h"

@class Message;
@class FileUploadResponse;

//OTRChatState
enum{
    kOTRChatStateUnknown =0,
    kOTRChatStateActive = 1,
    kOTRChatStateComposing = 2,
    kOTRChatStatePaused = 3,
    kOTRChatStateInactive = 4,
    kOTRChatStateGone =5
};
typedef NSInteger OTRChatState;


@protocol ChatMessageDelegate <NSObject>
-(void) handleAllMessageLoaded:(NSObject*) aObject;
-(void) handleMessageListChange:(NSObject*) aObject;
-(void) handleChatStateChange:(OTRChatState)aState;
@end

@interface Chat : NSObject

@property (nonatomic, assign) IBOutlet id<ChatMessageDelegate> chatDelegate;
@property (nonatomic, retain) NSString* chatJid;
-(id)initWithChatJID:(NSString *)aJID withName:(NSString*) aName;

-(NSInteger) lastMessageId;
-(NSDate*) lastActivityDate;
-(NSString*) lastMessage;
-(NSString*) chatBareJid;
-(NSString*) getDisplayName;
-(UIImage*) chatImage;

// method which are called to setup chat data last activity
-(void) setChatImage:(UIImage*) image;
-(void) setLastMessage:(NSString*) message withTime:(NSString*) aTime withUnread:(NSInteger) aUnreadCount messageId:(NSInteger) messageNumber;

// method called from below layers
-(void) handleMessageDelivered:(Message*) aMessage;
-(void) handleRecievedMessage:(Message *)message;
-(void) handleChatStateRecieved:(OTRChatState) chatState;

// method called from UI layers
-(void) loadMessagesFromDB;
-(BOOL) isActiveChat;
-(void) setActive:(BOOL) isActive;
-(NSInteger) unreadCount;
-(NSArray*) allUiMessageArray;
-(void) sendChatMessage:(Message*)message;

@end
