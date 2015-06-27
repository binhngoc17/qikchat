//
//  AppDelegate.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"

@class SettingsViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, XMPPRosterDelegate>
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
	
	UIWindow *window;
}

@property(strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, strong) IBOutlet UITabBarController *tabController;
@property (nonatomic, strong) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_message;
-(XMPPUserCoreDataStorageObject*) managedObjectContext_forUser:(XMPPJID*) aJid;

- (BOOL)connect;
- (void)disconnect;

@end
