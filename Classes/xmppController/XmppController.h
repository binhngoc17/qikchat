//
//  XmppController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 28/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "QikAChat-Prefix.pch"
#import "XMPPFramework.h"
#import "Literals.h"
#import "RosterController.h"
#import "MessageController.h"

@interface XmppController : NSObject<XMPPStreamDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
   
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    
    RosterController* rosterController;
    MessageController* mesageController;

}

+(XmppController *)sharedSingleton;

-(RosterController*) rosterController;
-(MessageController*) messageController;

- (BOOL)isServiceConnected;
- (BOOL)connect;
- (void)disconnect;
- (void)closeInstance;

@end
