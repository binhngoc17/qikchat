//
//  MessageController.m
//  ChatNA
//
//  Created by Ram Bhawan Chauhan on 13/08/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//
#import "MessageController.h"

#import "XmppController.h"
#import "Message.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0085.h"
#import "NSXMLElement+XMPP.h"
#import "Buddy.h"
#import "DDXML.h"
#import "DDLog.h"
#import "Chat.h"
#import "StorageManager.h"
#import "FileUploadResponse.h"
#import "FileUploadRequest.h"
#import "ChatNaController.h"
#import "NSData+Base64.h"
#import "XMPPMessageDeliveryReceipts.h"

@implementation MessageController

-(id) initWithStream:(XMPPStream*)xmppStream
{
    self = [super init];
    
    if(self)
    {
        _xmppStream = xmppStream;
        [self setup];
    }
    return self;
}

- (void) setup
{
     _allChatList  = [[NSMutableDictionary alloc] init];
	 _allPendingFileUpload = [[NSMutableDictionary alloc] init]; // file message queue
     _allWaitingMessageQueue = [[NSMutableArray alloc] init];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] init];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = NO;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageDeliveryRecipts activate:_xmppStream];
    
   
    [self loadAllChats];
    
    NSArray* array = [[StorageManager sharedInstance] getAllChatMessagesForState:MESSAGE_STATUS_WAITING];
    [_allWaitingMessageQueue addObjectsFromArray:array];
    
}


/*
 *call it in delloc of to tear down connection
 */
- (void)teardown
{
    
}

/* @author - Babul Prabhakar
 * recieve Message delegate for reciveing message
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
   
    if ([message isMessageWithBody] && ![message isErrorMessage])
    {
        // message
        Message *msg = [self parse2LocalMessage:message ];
        if( msg )
        {
            msg.isOutGoing = FALSE;
            Chat* chat = [self createChatForJID:msg.bareJid withDisplayName:nil];
            if( chat ){
                [chat handleRecievedMessage:msg];
                
                if([message hasReceiptRequest])
                {
                    XMPPMessage *generatedReceiptResponse = [message generateReceiptResponse];
                    NSXMLElement *received = [generatedReceiptResponse elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
                    if( [chat isActiveChat] )
                    {
                        [received addAttributeWithName:@"read" stringValue:@"true"];
                    }
                    else
                    {
                        [received addAttributeWithName:@"read" stringValue:@"false"];
                    }
                    [sender sendElement:generatedReceiptResponse];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_LIST_UPDATE object:nil];
        }
    }
    else if ([message hasReceiptResponse] && ![message isErrorMessage])
    {
        //delivery report
        NSString* bareJid = message.from.bare;
        NSArray* allIdParts = [[message receiptResponseID] componentsSeparatedByString:@"-"];
        NSInteger msgId = [[allIdParts lastObject] intValue];
      
        MessageStatus status = MESSAGE_STATUS_USER;
        
        NSXMLElement *received = [message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
        if( received )
        {
            NSString* readValue = [received attributeStringValueForName:@"read"];
            if( [readValue isEqualToString:@"true"] )
                status = MESSAGE_STATUS_READ;
        }
        
        [[StorageManager sharedInstance] updateMessageStatus:status bareJId:bareJid messageId:msgId];
      
        Chat* chat = [self getChatForJID:bareJid];
        if( chat )
        {
            if ([chat.chatDelegate conformsToProtocol:@protocol(ChatMessageDelegate)] && [chat.chatDelegate respondsToSelector:@selector(handleMessageChange:messageId:status:)]) {
                [chat.chatDelegate handleMessageChange:bareJid messageId:msgId status:status];
            }
        }
    }
    else if([message hasChatState] && ![message isErrorMessage])
    {
        //delivery report
        NSString* bareJid = message.from.bare;
        Chat* chat = [self getChatForJID:bareJid];
        if( chat )
        {
            OTRChatState newState = kOTRChatStateUnknown;
            if( [message hasActiveChatState])
                newState = kOTRChatStateActive;
            else if( [message hasComposingChatState])
                newState = kOTRChatStateComposing;
            else if( [message hasPausedChatState])
                newState = kOTRChatStatePaused;
            else if( [message hasInactiveChatState])
                newState = kOTRChatStateInactive;
            else if( [message hasGoneChatState])
                newState = kOTRChatStateGone;
       
            if( newState == kOTRChatStateActive || newState == kOTRChatStateComposing)
            {
                // mark all message read for this chat
                [[StorageManager sharedInstance] updateMessageStatus:MESSAGE_STATUS_READ bareJId:bareJid messageId:0]; // all messages
            }
 
            if ([chat.chatDelegate conformsToProtocol:@protocol(ChatMessageDelegate)] && [chat.chatDelegate respondsToSelector:@selector(handleChatState:state:)])
            {
                [chat.chatDelegate handleChatState:bareJid state:newState];
            }
        }
   }
}

-(void) handleServiceAuthenticated
{
    if( [_allWaitingMessageQueue count] && !_isMessageSending)
    {
        //start timer 3 second delay for complete ready to send
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(sendQueueMessage:) userInfo:nil repeats:NO] ;
        _isMessageSending = YES;
    }
}

-(void) asynchSendQueueMessage
{
    if( [_allWaitingMessageQueue count] && !_isMessageSending)
    {
        //start timer
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendQueueMessage:) userInfo:nil repeats:NO] ;
        _isMessageSending = YES;
    }
}

-(void) sendQueueMessage:(NSTimer*) aTimer
{
    Message* firstMessage = [_allWaitingMessageQueue firstObject];
    
    [self processSendMessage:firstMessage];
    
}

-(void)sendOrQueueChatMessage:(Message *)message
{
    if( [[XmppController sharedSingleton]  isServiceConnected] && !_isMessageSending)
    {
        [self processSendMessage:message];
    }
    else
    {
        [self queueMessage:message];
    }
}

-(void) processSendMessage:(Message*) message
{
    // check connection here
    if( message.messageType == TEXT_TYPE_MESSAGE )
    {
        [self doSendChatMessage:message withErr:0];
    }
    else if(  message.messageType == LOCATION_TYPE_MESSAGE )
    {
        [self doSendChatMessage:message withErr:0];
    }
    else if( message.fileData )
    {
        FileUploadRequest *fileupload = [[FileUploadRequest alloc] initWithJid:message.bareJid];
        
        fileupload.exten = [Constants contentTypeForImageData:message.fileData];
        fileupload.fileType = [Constants getStringMessageType:message.messageType];
        
        NSString *filename = [message.body lastPathComponent];
        [fileupload setFileName:filename];
        
        if( message.messageType == VIDEO_TYPE_MESSAGE )
        {
            fileupload.exten = [NSString stringWithFormat:@"video/%@",[filename pathExtension] ];
        } else if (message.messageType == AUDIO_TYPE_MESSAGE) {
            fileupload.exten = @"audio/m4a";
        }
        
        fileupload.data = [message.fileData base64EncodedString];
        message.extension = fileupload.exten;
        
        [_allPendingFileUpload setObject:message forKey:[fileupload getRequestId] ];
        
        [[ChatNaController sharedInstance] uploadMultiPartFile:fileupload];
        
        if( message.messageType == VIDEO_TYPE_MESSAGE ) // for displaying thumb
        {
            message.fileData = nil; // do not save whole data in db,  remove it
        }
    }
    else if( _isMessageSending )
    {
        _isMessageSending = NO;
        [self asynchSendQueueMessage];
    }
}



-(void)sendorQueueForwardMessages:(Message *)message {
    if( [[XmppController sharedSingleton]  isServiceConnected] && !_isMessageSending)
    {
        [self doSendChatMessage:message withErr:0];
    }
    else
    {
        [self queueMessage:message];
    }
}








-(void) doSendChatMessage:(Message*) aMessage withErr:(NSInteger) error
{
    if( error >=0 )
    {
        [self sendMessage:aMessage];
        aMessage.messageStatus = MESSAGE_STATUS_SERVER;
    }
    else{
        aMessage.messageStatus = MESSAGE_STATUS_FAILED;
    }
    
    [[StorageManager sharedInstance] updateChatMessage:aMessage];
    
    [_allWaitingMessageQueue removeObject:aMessage];

    Chat* chat = [self getChatForJID:aMessage.bareJid];
    if( chat ){
        if ([chat.chatDelegate conformsToProtocol:@protocol(ChatMessageDelegate)] && [chat.chatDelegate respondsToSelector:@selector(handleMessageSent:)]) {
        [chat.chatDelegate handleMessageSent:aMessage];
        }
    }
    
    _isMessageSending = NO;
    [self asynchSendQueueMessage];
}

-(void) handleFileUploadResponse:(FileUploadResponse*) aFileRespone error:(int) err
{
    _isMessageSending = NO;
    
    if( !aFileRespone ){
        [self asynchSendQueueMessage];
        return;
    }
    
    Message* message = [_allPendingFileUpload objectForKey:[aFileRespone getRequestId]];
    if( message )
    {
        message.lresURL = (aFileRespone.lresURL == nil) ? @"" : aFileRespone.lresURL;
        message.hresURL = aFileRespone.hresURL;
        [_allPendingFileUpload removeObjectForKey:[aFileRespone getRequestId]];
        
        [self doSendChatMessage:message withErr:err];
    }
}

-(void) queueMessage:(Message*) chatMessage
{
    [_allWaitingMessageQueue addObject:chatMessage];
}

/* @author - Babul Prabhakar
 * send Message through xmpp stream
 *properties i.e elements as is used by android version for chatna
 * - params -  Message type
 */
- (void) sendMessage:(Message*)chatMessage {
    NSString *messageStr = chatMessage.body;
   // if ([messageStr length] >0)
    {
        NSString *messageID=[_xmppStream generateUUID];
        
        XMPPJID* xmppjid = _xmppStream.myJID;
        
        NSString *id = [NSString stringWithFormat:@"%@-%ld",messageID, (long)chatMessage.messageNumber];
        
      	NSXMLElement *message = [NSXMLElement elementWithName:TAG_MESSAGE];
        [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
        [message addAttributeWithName:@"id" stringValue:id];
        
		[message addAttributeWithName:@"to" stringValue:chatMessage.bareJid];
        [message addAttributeWithName:@"from" stringValue:xmppjid.full];
        
        [message addAttributeWithName:TAG_TYPE stringValue:@"chat"];
		
        NSXMLElement * thread = [NSXMLElement elementWithName:@"thread"];
        [thread setStringValue:@"wj2hPxTzW2Nt"];
        [message addChild:thread];
        

       // NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
        //[receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        //[message addChild:receiptRequest];
        
        NSXMLElement *properties = [NSXMLElement  elementWithName:KTAG_PROPERTIES];
        [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        
        if( chatMessage.messageType != TEXT_TYPE_MESSAGE )
        {
            
            if (chatMessage.messageType == LOCATION_TYPE_MESSAGE) {
                NSXMLElement *body = [NSXMLElement elementWithName:TAG_BODY];
                [body setStringValue:messageStr];
                [message addChild:body];
            } else {
                NSXMLElement *body = [NSXMLElement elementWithName:TAG_BODY];
                [body setStringValue:@""];
                [message addChild:body];
            }

            if( chatMessage.extension )
            {
                NSXMLElement *property = [NSXMLElement  elementWithName:KTAG_PROPERTY];
         
                NSXMLElement *name = [NSXMLElement  elementWithName:KTAG_NAME];
                [name setStringValue:KTAG_EXTENSION];
                [property addChild:name];
         
                NSXMLElement *value = [NSXMLElement  elementWithName:KTAG_VALUE];
                [value addAttributeWithName:@"type" stringValue:KTAG_STRING];
                [value setStringValue:chatMessage.extension];
                [property addChild:value];
           
                [properties addChild:property];
            }
        
            if( chatMessage.hresURL )
            {
                NSXMLElement *property = [NSXMLElement  elementWithName:KTAG_PROPERTY];
           
                NSXMLElement *name = [NSXMLElement  elementWithName:KTAG_NAME];
                if (chatMessage.messageType == LOCATION_TYPE_MESSAGE) {
                    [name setStringValue:TAG_LAT];
                } else {
                    [name setStringValue:KTAG_HRESURL];
                }
                
                [property addChild:name];
           
                NSXMLElement *value = [NSXMLElement  elementWithName:KTAG_VALUE];
                [value addAttributeWithName:@"type" stringValue:KTAG_STRING];
                [value setStringValue:chatMessage.hresURL];
                [property addChild:value];
           
                [properties addChild:property];
            }
        
            if( chatMessage.lresURL )
            {
                NSXMLElement *property = [NSXMLElement  elementWithName:KTAG_PROPERTY];
           
                NSXMLElement *name = [NSXMLElement  elementWithName:KTAG_NAME];
                // new lat lnt details
               NSString *nameTag = (chatMessage.messageType == LOCATION_TYPE_MESSAGE)?TAG_LNG :KTAG_LRESURL;
                [name setStringValue:nameTag];
                [property addChild:name];
           
                NSXMLElement *value = [NSXMLElement  elementWithName:KTAG_VALUE];
                [value addAttributeWithName:@"type" stringValue:KTAG_STRING];
                [value setStringValue:chatMessage.lresURL];
                [property addChild:value];
           
                [properties addChild:property];
            }
        
            if( chatMessage.size )
            {
                NSXMLElement *property = [NSXMLElement  elementWithName:KTAG_PROPERTY];
                
                NSXMLElement *name = [NSXMLElement  elementWithName:KTAG_NAME];
                [name setStringValue:KTAG_SIZE];
                [property addChild:name];
                
                NSXMLElement *value = [NSXMLElement  elementWithName:KTAG_VALUE];
                [value addAttributeWithName:@"type" stringValue:KTAG_LONG];
                [value setStringValue:chatMessage.size];
                
                [property addChild:value];
                
                [properties addChild:property];
            }
        } else {
            NSXMLElement *body = [NSXMLElement elementWithName:TAG_BODY];
            [body setStringValue:messageStr];
            [message addChild:body];
        }
        
       
        
        if( chatMessage.messageType >=0 )
        {
            NSXMLElement *property = [NSXMLElement  elementWithName:KTAG_PROPERTY];
            
            NSXMLElement *name = [NSXMLElement  elementWithName:KTAG_NAME];
            [name setStringValue:KTAG_MESSAGETYPE];
            [property addChild:name];
            
            NSXMLElement *value = [NSXMLElement  elementWithName:KTAG_VALUE];
            [value addAttributeWithName:@"type" stringValue:KTAG_STRING];
            [value setStringValue:[Constants getStringMessageType:chatMessage.messageType]];
            [property addChild:value];
       
            [properties addChild:property];
        }
        
        
        [message addChild:properties];
        
    
        XMPPMessage * xMessage = [XMPPMessage messageFromElement:message];
        [xMessage addActiveChatState];
		
        [_xmppStream sendElement:message];
        
    }
}


/*
 *@author - Ram Chauhan
 *method returns array of chats
 */
-(void) updateChatInfoIfExists:(Buddy*) aBuddy
{
    if( aBuddy == nil)
        return;
    
    Chat *chat = [_allChatList objectForKey:aBuddy.accountName ];
    if( chat )
    {
        [chat setChatDisplayName:[aBuddy getDisplayName]];
        [chat setChatImage:aBuddy.avatarImage];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_LIST_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CHAT_INFO object:chat];
    }
}

//get image From String

-(void)sendChatState:(int)chatState toJId:(NSString *)toJid
{
    NSXMLElement *message = [NSXMLElement elementWithName:TAG_MESSAGE];
    [message addAttributeWithName:TAG_TYPE stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:toJid];
    XMPPMessage * xMessage = [XMPPMessage messageFromElement:message];
    
    BOOL shouldSend = YES;
    
    switch (chatState)
    {
        case kOTRChatStateActive  :
            [xMessage addActiveChatState];
            break;
        case kOTRChatStateComposing  :
            [xMessage addComposingChatState];
            break;
        case kOTRChatStateInactive:
            [xMessage addInactiveChatState];
            break;
        case kOTRChatStatePaused:
            [xMessage addPausedChatState];
            break;
        case kOTRChatStateGone:
            [xMessage addGoneChatState];
            break;
        default :
            shouldSend = NO;
            break;
    }
    
    if(shouldSend)
        [_xmppStream sendElement:message];
    
}


-(void)requestOfflineMessages
{
    XMPPIQ *iq = [[XMPPIQ alloc] init];
    [iq addAttributeWithName:TAG_TYPE stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"fetch1"];
    
    
    NSXMLElement *offline = [NSXMLElement elementWithName:@"offline"];
    
    [offline addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/offline"];
    
    
    NSXMLElement *fetch = [NSXMLElement elementWithName:@"fetch"];
    
    [offline addChild:fetch];
    
    [iq addChild:offline];
    
    [_xmppStream sendElement:iq];
}


-(void)removeOfflineMessages
{
    XMPPIQ *iq = [[XMPPIQ alloc] init];
    [iq addAttributeWithName:TAG_TYPE stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"purge1"];
    
    
    NSXMLElement *offline = [NSXMLElement elementWithName:@"offline"];
    
    [offline addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/offline"];
    
    
    NSXMLElement *fetch = [NSXMLElement elementWithName:@"purge"];
    
    [offline addChild:fetch];
    
    [iq addChild:offline];
    
    [_xmppStream sendElement:iq];
}


/*
 *@author - Babul Prabhakar
 *method returns array of messages
 */
-(void) loadAllChats
{
    [_allChatList removeAllObjects];
    NSDictionary* allStoredRoster = [[[XmppController sharedSingleton] rosterController] getAllStorageRoster];
    [[StorageManager sharedInstance] loadAllChatList:_allChatList forRosters:allStoredRoster];
}

/*
 *@author - Ram Chauhan
 *method returns array of chats
 */
-(NSArray*) getAllChatList
{
    NSArray* array = [_allChatList allValues];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastDate" ascending:NO ];
	NSArray* desc = [NSArray arrayWithObject:sort];
	
    NSMutableArray* sortedArray = [[NSMutableArray alloc] initWithArray:array];
	[sortedArray sortUsingDescriptors:desc];
    
    return sortedArray;

}



-(void)removeChat:(NSString *)jid {
    
    [_allChatList removeObjectForKey:jid];
}

-(NSInteger) getAllUnreadCounts
{
    NSInteger unreadCount = 0 ;
    NSArray* allvalues = [_allChatList allValues];
    for( Chat* chat in allvalues )
    {
        unreadCount = unreadCount + [chat unreadCount];
    }
    return unreadCount;
}

-(Chat*) createChatForJID:(NSString*) Jid withDisplayName:(NSString*) aName
{
    if( Jid == nil )
        return nil;
    
    Chat* chat = [_allChatList objectForKey:Jid];
    if( !chat )
    {
        chat = [[Chat alloc] initWithChatJID:Jid withName:aName];
        [_allChatList setObject:chat forKey:Jid];
        [[StorageManager sharedInstance] saveChat:chat];
    }
    return chat;
}


-(Chat*) getChatForJID:(NSString*) Jid
{
    Chat* chat = [_allChatList objectForKey:Jid];
    return chat;
}

-(Message*) parse2LocalMessage:(XMPPMessage*) aXMPPMessage
{
    Message *msg = nil;
    
    if( ![aXMPPMessage isErrorMessage] )
    {
        // message
        NSString *body = [[aXMPPMessage elementForName:@"body"] stringValue];
        XMPPJID* xmppjid = aXMPPMessage.from;
        NSString* jid = xmppjid.bare;
       	
        msg = [Message messageWithText:body withJid:jid];
        msg.messageType = TEXT_TYPE_MESSAGE;
        
        NSXMLElement *properties = [aXMPPMessage elementForName:KTAG_PROPERTIES];
        if (properties)
        {
            NSArray *propertys = [properties elementsForName:KTAG_PROPERTY];
            for (int i=0; i<[propertys count]; i++)
            {
                NSXMLElement *property = [propertys objectAtIndex:i];
               
                NSString *name = [[property elementForName:@"name"] stringValue];
                NSString *value = [[property elementForName:@"value"] stringValue];
                
                if( [name isEqualToString:KTAG_MESSAGETYPE] )
                {
                    msg.messageType = [Constants getMessageType:value];
                }
                else if( [name isEqualToString:KTAG_HRESURL]  )
                {
                    msg.hresURL = value;
                }
                else if( [name isEqualToString:KTAG_LRESURL]  )
                {
                    msg.lresURL = value;
                }
                else if( [name isEqualToString:KTAG_EXTENSION]  )
                {
                    msg.extension = value;
                }
                else if( [name isEqualToString:KTAG_SIZE]  )
                {
                    msg.size = 0;
                } else if ([name isEqualToString:TAG_LAT]) {
                    msg.hresURL = value;
                } else if([name isEqualToString:TAG_LNG]) {
                    msg.lresURL = value;
                }
                
                
            }
        }
    }
    return msg;
}


@end
