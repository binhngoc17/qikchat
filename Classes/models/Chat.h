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
@optional
-(void) handleMessageSent:(Message*) aMessage;
-(void) handleMessageChange:(NSString*) aBareJid messageId:(NSInteger)messageId status:(MessageStatus) newState;
-(void) handleChatState:(NSString*) aBareJid state:(OTRChatState) newState;
@end

@interface Chat : NSObject
{
    Message* _lastMessage;
    UIImage* _image;
    NSString* _displayName;
    BOOL _isCurrentlyActive;
    NSInteger _unreadCount;
    NSMutableArray* _allUnreadMessages; //unread messages
    NSMutableArray* _allMessages;
}
@property (nonatomic, assign) IBOutlet id<ChatMessageDelegate> chatDelegate;
@property (nonatomic, retain) NSString* chatJid;


@property (nonatomic) NSInteger numberOfMessagesSent;
@property (nonatomic) OTRChatState lastSentChatState;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSTimer * pausedChatStateTimer;
@property (nonatomic, strong) NSTimer * inactiveChatStateTimer;

-(id)initWithChatJID:(NSString *)aJID withName:(NSString*) aName;
-(NSInteger) lastMessageId;
-(NSDate*) lastActivityDate;
-(NSString*) lastMessage;
-(NSString*) chatBareJid;
-(NSString*) getDisplayName;
-(UIImage*) chatImage;
-(void) setChatImage:(UIImage*) image;
-(void) setChatDisplayName:(NSString*) aDisplayName;
-(void) setLastMessage:(NSString*) message withTime:(NSString*) aTime withUnread:(NSInteger) aUnreadCount messageId:(NSInteger) messageNumber;

-(void)receiveChatStateMessage:(OTRChatState) chatState;

-(void)restartPausedChatStateTimer;
-(void)restartInactiveChatStateTimer;
-(void)sendPausedChatState;
-(void)sendActiveChatState;
-(void)sendInactiveChatState;
-(void)sendComposingChatState;

-(void) sendChatMessage:(Message *)message;
-(void) handleRecievedMessage:(Message *)message;
-(void) handleFileDownloaded:(Message*) aMessage error:(int) err;

-(void) asynchLoadAllMessages;
-(BOOL) isActiveChat;
-(void) setActive:(BOOL) isActive;
-(NSInteger) unreadCount;

-(void)updateLastChat:(Message *)message;

-(NSArray*) allMessageArray;

@end