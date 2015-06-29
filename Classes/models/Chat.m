//
//  Chat.m
//  ChatNA
//
//  Created by Ram Bhawan Chauhan on 30/08/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//

#import "Chat.h"
#import "Buddy.h"
#import "Message.h"
#import "XmppController.h"
#import "MessageController.h"
#import "NSString+HTML.h"
#import "Strings.h"
#import "DDLog.h"
#import "ThemeManager.h"
#import "SettingsController.h"
#import "FileUploadResponse.h"
#import "FileUploadRequest.h"
#import "ChatNaController.h"
#import "NSData+Base64.h"
#import "StorageManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TWMessageBarManager.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioServices.h>

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
        [self setChatDisplayName:aName];
        
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
        _allUnreadMessages = [[NSMutableArray alloc] init];
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
        [[StorageManager sharedInstance] updateLastActivity:self];
        
        if( !_isCurrentlyActive || [_allUnreadMessages count] )
        {
            [self asynchPushPendingMessages];
        }
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
        _lastMessage.date = [Constants stringToDate:aTime withFormat:kChatTimestampFormat];
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



-(void)updateLastChat:(Message *)message {
   
    _lastMessage = message;
    self.lastDate = _lastMessage.date;
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
}

-(NSString*) getDisplayName
{
     if( _displayName )
         return _displayName;
    
    return [Constants bareName:self.chatJid];
}

-(void) setChatDisplayName:(NSString*) aDisplayName
{
    NSRange atRange = [aDisplayName rangeOfString:[NSString stringWithFormat:@"@%@",DOMAIN_NAME_XMPP_CHATNA]];
    if (atRange.location == NSNotFound && aDisplayName.length )
    {
        _displayName = aDisplayName; // replace state away
        [[StorageManager sharedInstance] updateChatName:self];
    }
    else if( aDisplayName.length && _displayName==nil )
    {
        _displayName = [aDisplayName substringToIndex:atRange.location];
        [[StorageManager sharedInstance] updateChatName:self];
    }
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
    [[[XmppController sharedSingleton] messageController ] sendChatState:sendingChatState toJId:self.chatJid];
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

-(void)receiveChatStateMessage:(OTRChatState) newChatState
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
}


-(void) handleRecievedMessage:(Message *)message
{
    if (message)
    {
        message.isOutGoing = NO;
        
        if( message.messageType == IMAGE_TYPE_MESSAGE  && message.lresURL != nil )
        {
            [self asynchDownloadMedia:message];
        }
        else if( message.messageType == VIDEO_TYPE_MESSAGE  && message.lresURL != nil )
        {
            [self asynchDownloadMedia:message];
        }
        else
        {
            [self doHandleReceivedMessage:message];
        }
    }
}

-(void) handleFileDownloaded:(Message*) message  error:(int) err;
{
    [self doHandleReceivedMessage:message];
}

-(void) doHandleReceivedMessage:(Message*) aMessage
{
    
    NSString* displayName = [self getDisplayName];
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
    
    if (![[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
    {
        _unreadCount++;
        [_allUnreadMessages addObject:aMessage];
        [self saveChatMessage:aMessage];
        
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = REPLY_STRING;
        //check from data controller that user has defined the messageController yes or not;
        if ([[SettingsController sharedInstance] isMessageToneOn]) {
             localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        if ([[SettingsController sharedInstance] isMessageVibrateChecked]) {
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
        [_allUnreadMessages addObject:aMessage];
        [self saveChatMessage:aMessage];
        
        NSString* bodyMsg = [NSString stringWithFormat:@"%@: %@",displayName,self.lastMessage];
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"ChatNA"
                                                       description:bodyMsg
                                                              type:TWMessageBarMessageTypeInfo
                                                    statusBarStyle:UIStatusBarStyleLightContent callback:^{
                                                        
                                                        [[AppDelegate sharedInstance] activateChatView:self];

                                                    }
         ];
        
        [self playSystemSound];
        
    }
    else
    {
        [self saveChatMessage:aMessage];
        [self playSystemSound];
        
        NSDictionary *messageInfo = [NSDictionary dictionaryWithObject:aMessage forKey:MESSAGE_KEY_FOR_MESSAGE];
        //save it to db and show to user on chat list and chat screen
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_RECIEVED object:self userInfo:messageInfo];
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
    [self saveChatMessage:message];
    
    [[[XmppController sharedSingleton]  messageController] sendOrQueueChatMessage:message];
    
}

-(void) asynchDownloadMedia:(Message*) aOperationId
{
    [NSThread detachNewThreadSelector:@selector(downloadMediaData:) toTarget:self withObject:aOperationId];
}

-(void) downloadMediaData:(Message*)aOperationId
{
    [[ChatNaController sharedInstance] downloadRecievedFile:aOperationId forChat:self];
}

-(void) asynchLoadAllMessages
{
    [NSThread detachNewThreadSelector:@selector(loadMessages) toTarget:self withObject:nil];
}

-(void)loadMessages{
    
    [_allUnreadMessages removeAllObjects]; // loading message from db , just clear the local list
    
   [[StorageManager sharedInstance] loadAllChatMessags:self.chatJid];
   
}


- (NSData *)thumbnailImageForVideo:(NSString *)videoURL
                             atTime:(NSTimeInterval)time
{
    NSURL *url = [NSURL fileURLWithPath:videoURL];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", igError );
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return UIImagePNGRepresentation(thumbnailImage);
}


-(void) asynchPushPendingMessages
{
    if( [_allUnreadMessages count] ){
        [NSThread detachNewThreadSelector:@selector(pushPendingMessages) toTarget:self withObject:nil];
    }
}

-(void) pushPendingMessages
{
    for( Message* message in _allUnreadMessages )
    {
        NSDictionary *messageInfo = [NSDictionary dictionaryWithObject:message forKey:MESSAGE_KEY_FOR_MESSAGE];
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_CHAT_LOADED object:self userInfo:messageInfo];
    }
    
    [_allUnreadMessages removeAllObjects];
}



-(void)forwardMessages:(NSMutableArray *)fowardMessagesArray {
    
    
    for (NSObject *obj  in fowardMessagesArray)
    {
        if ([obj isKindOfClass:[Message class]]) {
            Message *message = (Message *)obj;
            message.isOutGoing = YES;
            message.messageStatus = MESSAGE_STATUS_WAITING;
            message.bareJid = self.chatJid;
            [self saveChatMessage:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_SENT_CHAT object:message];
            [[[XmppController sharedSingleton]  messageController] sendorQueueForwardMessages:message];
        }
       

    }
    
    
}

@end
