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

@interface XmppController : NSObject<XMPPRosterDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPMessageArchivingCoreDataStorage* xmppMessageArchivingStorage;
    XMPPMessageArchiving* xmppMessageArchivingModule;

    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    
    RosterController* rosterController;
    MessageController* mesageController;
}

+(XmppController *)sharedSingleton;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

-(RosterController*) rosterController;
-(MessageController*) messageController;

- (NSManagedObjectContext *)managedObjectContext_message;

- (BOOL)isServiceConnected;
- (BOOL)connect;
- (void)disconnect;
- (void)closeInstance;

@end
