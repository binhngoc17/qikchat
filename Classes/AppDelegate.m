//
//  AppDelegate.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "ChatsViewController.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>
#import "QikAChat-Prefix.pch"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

@synthesize window;
@synthesize tabController;
@synthesize settingsViewController;
@synthesize loginButton;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup the XMPP stream
    [XmppController sharedSingleton];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:headerColor];
    
    FriendsViewController* rootViewController1 = [[FriendsViewController alloc] init];
    UINavigationController* navigationController1 = [[UINavigationController alloc] initWithRootViewController:rootViewController1];
    
    ChatsViewController* rootViewController2 = [[ChatsViewController alloc] init];
    UINavigationController* navigationController2 = [[UINavigationController alloc] initWithRootViewController:rootViewController2];
  
    navigationController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"tab_friends"] tag:0] ;
    
    navigationController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"tab_chats"] tag:1] ;
    
    self.tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = [NSArray arrayWithObjects:navigationController1,navigationController2, nil];
    
    if ( ![xmppInstance connect])
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
            //[self.tabController presentViewController:settingsViewController animated:YES completion:NULL];
        });
    }
    
    [self.window setRootViewController:self.tabController];
    [self.window makeKeyAndVisible];
  
	return YES;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application 
{
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	// 
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
	#endif

	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) 
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  
    [xmppInstance closeInstance];
}

@end
