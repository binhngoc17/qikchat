//
//  Chat.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "Chat.h"
#import "Buddy.h"
#import "Message.h"
#import "XmppController.h"
#import "MessageController.h"
#import "DDLog.h"
#import "Strings.h"
#import "StorageManager.h"
#import "ProfileDataManager.h"
#import "Literals.h"
#import "UIMessageBarManager.h"
#import "NSBubbleData.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioServices.h>

@interface Chat()
{
    Message* _lastMessage;
    UIImage* _image;
    NSString* _displayName;
    BOOL _isCurrentlyActive;
    NSInteger _unreadCount;
    NSMutableArray* _allUiMessages;
}

@property (nonatomic) OTRChatState lastSentChatState;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSTimer * pausedChatStateTimer;
@property (nonatomic, strong) NSTimer * inactiveChatStateTimer;

@end

@implementation Chat


@synthesize lastSentChatState;
@synthesize inactiveChatStateTimer;
@synthesize pausedChatStateTimer;
@synthesize chatDelegate;

- (id)initWithChatJID:(NSString *)aJID withName:(NSString*) aName
{
    self = [super init];
    if ([self init])
    {
        // Custom initialization
        self.chatJid = aJID;
        _displayName =  aName;
    }
    return self;
}

-(id) init
{
    if(self)
    {
        self.chatDelegate = nil;
        self.chatJid = nil;
       
        self.lastSentChatState = 0;
        self.lastDate = nil;
        self.inactiveChatStateTimer = nil;
        self.pausedChatStateTimer = nil;
        _lastMessage = nil;
        _displayName = nil;
        _isCurrentlyActive = NO;
        _unreadCount = 0;
        _allUiMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) setActive:(BOOL) isActive
{
    if( isActive )
    {
        NSInteger remainingBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - _unreadCount;
        if( remainingBadgeNumber < 0 )
            remainingBadgeNumber = 0;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:remainingBadgeNumber] ;
        _unreadCount = 0;
        
        [self sendActiveChatState];
    }
    else
    {
        [self sendInactiveChatState];
    }
    
    _isCurrentlyActive = isActive;
}

-(BOOL) isActiveChat
{
    return _isCurrentlyActive;
}

-(NSInteger) unreadCount
{
    return _unreadCount;
}

-(void) setLastMessage:(NSString*) message withTime:(NSString*) aTime withUnread:(NSInteger) aUnreadCount messageId:(NSInteger) messageNumber
{
    if( !_lastMessage && message.length > 0 )
    {
        _lastMessage = [Message new];
        _lastMessage.body = message;
        _lastMessage.date = [Utility stringToDate:aTime withFormat:kChatTimestampFormat];
        _lastMessage.messageNumber = messageNumber;
        
        self.lastDate = _lastMessage.date;
    }
    _unreadCount = aUnreadCount;
}

-(void) saveChatMessage:(Message*)message
{
    if( _lastMessage )
        message.messageNumber =  _lastMessage.messageNumber+1;
    else
        message.messageNumber =  1;
    
    _lastMessage = message;
    
    self.lastDate = _lastMessage.date;
    
    [[StorageManager sharedInstance] storeChatMessage:message];
    [[StorageManager sharedInstance] updateLastActivity:self];
    
    
}


-(NSInteger) lastMessageId
{
    if( _lastMessage )
    {
        return _lastMessage.messageNumber;
    }
    return 1;
}

-(NSString*) lastMessage
{
    if( _lastMessage )
    {
        if( _lastMessage.messageType == TEXT_TYPE_MESSAGE )
        {
            return _lastMessage.body;
        }
        else if( _lastMessage.messageType == LOCATION_TYPE_MESSAGE )
        {
            return @"Location Message";
        }
        else if (_lastMessage.messageType == VIDEO_TYPE_MESSAGE)
        {
            return @"Video";
        }
        else if (_lastMessage.messageType == IMAGE_TYPE_MESSAGE)
        {
            return @"Image";
        }
        else if (_lastMessage.messageType == AUDIO_TYPE_MESSAGE)
        {
            return @"Audio";
        }
        else
        {
            return @"unknown mesage";
        }
    }
    return @"";
}

-(NSDate*) lastActivityDate
{
    if( _lastMessage )
    {
        return _lastMessage.date;
    }
    return nil;
}

-(NSString*) chatBareJid
{
    if( self.chatJid != nil )
        return self.chatJid;
    
    return _displayName;
}

-(NSString*) getDisplayName
{
     if( _displayName )
         return _displayName;
    
    return [Utility displayName:self.chatJid];
}

-(void) setChatImage:(UIImage*) image
{
    _image = image;
}

-(UIImage*) chatImage
{
    return _image;
}

-(void)sendChatState:(OTRChatState) sendingChatState
{
     lastSentChatState = sendingChatState;
}

-(void)sendComposingChatState
{
    if(self.lastSentChatState != kOTRChatStateComposing)
    {
        [self sendChatState:kOTRChatStateComposing];
    }
    [self restartPausedChatStateTimer];
    [self.inactiveChatStateTimer invalidate];
}

-(void)sendPausedChatState
{
    [self sendChatState:kOTRChatStatePaused];
    [self.inactiveChatStateTimer invalidate];
}

-(void)sendActiveChatState
{
    [pausedChatStateTimer invalidate];
    [self restartInactiveChatStateTimer];
    [self sendChatState:kOTRChatStateActive];
}

-(void)sendInactiveChatState
{
    [self.inactiveChatStateTimer invalidate];
    if(self.lastSentChatState != kOTRChatStateInactive)
        [self sendChatState:kOTRChatStateInactive];
}

-(void)restartPausedChatStateTimer
{
    [pausedChatStateTimer invalidate];
    pausedChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStatePausedTimeout target:self selector:@selector(sendPausedChatState) userInfo:nil repeats:NO];
}

-(void)restartInactiveChatStateTimer
{
    [inactiveChatStateTimer invalidate];
    inactiveChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStateInactiveTimeout target:self selector:@selector(sendInactiveChatState) userInfo:nil repeats:NO];
}

-(void) handleMessageDelivered:(Message*) aMessage{
    aMessage.messageStatus = MESSAGE_STATUS_WAITING;
    if( self.isActiveChat  )
        [self performSelectorOnMainThread:@selector(asynchNotifyMessageListChange:) withObject:aMessage waitUntilDone:NO];
}

-(void) asynchNotifyMessageListChange:(NSObject*) object
{
    if(self.chatDelegate && self.isActiveChat  ){
        [self.chatDelegate handleMessageListChange:object];
    }
}

-(void)handleChatStateRecieved:(OTRChatState) newChatState
{
   if( self.isActiveChat  )
       [self performSelectorOnMainThread:@selector(asynchNotifyChatStateRecieved:) withObject:[NSNumber numberWithInteger:newChatState] waitUntilDone:NO];
}

-(void) asynchNotifyChatStateRecieved:(NSObject*) object
{
    NSNumber* number = (NSNumber*) object;
    if(self.chatDelegate && self.isActiveChat ){
        [self.chatDelegate handleChatStateChange:number.integerValue];
    }
}

-(void) handleRecievedMessage:(Message *)message
{
    if (message)
    {
        message.isOutGoing = NO;
        [self doHandleReceivedMessage:message];
    }
}

-(void) doHandleReceivedMessage:(Message*) aMessage
{
     NSString* displayName = [self getDisplayName];
    [self addRecievedMessage:aMessage];
    
    if (![[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
    {
        _unreadCount++;
        
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = REPLY_STRING;
        //check from data controller that user has defined the messageController yes or not;
        if ([[ProfileDataManager sharedInstance] isMessageToneOn]) {
             localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        if ([[ProfileDataManager sharedInstance] isMessageVibrateChecked]) {
            //vibrate
        }
        localNotification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        localNotification.alertBody = [NSString stringWithFormat:@"%@: %@",displayName,self.lastMessage];
        localNotification.userInfo = @{NOTIFICATION_TYPE:CHAT_TYPE,
                                       CHAT_ID:self.chatBareJid
                                       ,CHAT_DISPLAY_NAME :displayName
                                       };
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
      
    }
    else if( !_isCurrentlyActive )
    {
        _unreadCount++;
       
        NSString* bodyMsg = [NSString stringWithFormat:@"%@: %@",displayName,self.lastMessage];
        
        [[UIMessageBarManager sharedInstance] showMessageWithTitle:@"QikAChat"
                                                       description:bodyMsg
                                                              type:UIMessageBarMessageTypeInfo
                                                    statusBarStyle:UIStatusBarStyleLightContent callback:^{
                                                        
                                                        [[UIController getUIController] activateChatView:self];
                                                        
                                                    }
         ];
        
        [self playSystemSound];
    }
    else
    {
        [self playSystemSound];
        
    }
}

-(void) playSystemSound
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
    SystemSoundID soundID = 0;
    if( path )
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    else
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:UILocalNotificationDefaultSoundName], &soundID);
    
    if( soundID == 0 ){
        //soundID = 0x00000FFF; vibration
        return;
    }
    
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);

}

-(void)sendChatMessage:(Message *)message
{
    if( !message )
        return;
   
    message.isOutGoing = YES;
    message.messageStatus = MESSAGE_STATUS_WAITING;
  
    [self addSentMessage:message];
    
    [[xmppInstance  messageController] sendOrQueueChatMessage:message];
}


-(void) asynchPushPendingMessages
{
    if( ![_allUiMessages count] ) {
        [[StorageManager sharedInstance] loadAllUiChatMessags:_allUiMessages forChatId:self.chatJid];
        if( self.isActiveChat )
            [self performSelectorOnMainThread:@selector(asynchNotifyMessageLoaded) withObject:Nil waitUntilDone:NO];
    }
}

-(void) loadMessagesFromDB
{
    if( ![_allUiMessages count] ) {
        // message all readlly in cache
        [NSThread detachNewThreadSelector:@selector(asynchPushPendingMessages) toTarget:self withObject:nil];
    }
}

-(void) asynchNotifyMessageLoaded{
    if(self.chatDelegate && _allUiMessages.count ){
        [self.chatDelegate handleAllMessageLoaded:_allUiMessages];
    }
}

-(NSArray*) allUiMessageArray{
    return _allUiMessages;
}

-(void) addSentMessage:(Message*) message
{
    [self saveChatMessage:message];
    
    NSBubbleData *sayBubble = [Utility createDataWithMessage:message];
    
    ProfileDataManager *myAccount = [ProfileDataManager sharedInstance];
    UIImage* avatarImage =  myAccount.myAvatar;
    sayBubble.avatar = avatarImage;
    
    [_allUiMessages addObject:sayBubble];
}

-(void) addRecievedMessage:(Message*) message
{
    [self saveChatMessage:message];
    
    if( self.isActiveChat || [_allUiMessages count] ){
        NSBubbleData *sayBubble = [Utility createDataWithMessage:message];
        sayBubble.avatar = self.chatImage;
        [_allUiMessages addObject:sayBubble];
    
        if( self.isActiveChat )
            [self performSelectorOnMainThread:@selector(asynchNotifyRecievedMessage) withObject:Nil waitUntilDone:NO];
    }
}

-(void) asynchNotifyRecievedMessage{
    if(self.chatDelegate && self.isActiveChat ){
        [self.chatDelegate handleMessageListChange:nil];
    }
}


@end
