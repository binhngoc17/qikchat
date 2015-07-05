//
//  UIController.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "UIController.h"
#include "Literals.h"
#import "QikAChat-Prefix.pch"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "ChatsViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"

static UIController *sharedUIController;

@implementation UIController

- (id)initWithWindow:(UIWindow *)window
{
    DASSERT([NSThread currentThread] == [NSThread mainThread]);
    self = [super init];
    if (self)
    {
        self.window = window;
        sharedUIController = self;
    }
    return self;
}

+(UIController*) getUIController{
    return sharedUIController;
}

-(void) showLoginScreen{
    
    LoginViewController* loginViewController = [[LoginViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
}

-(void) showMainScreen{
    
    FriendsViewController* rootViewController1 = [[FriendsViewController alloc] init];
    UINavigationController* navigationController1 = [[UINavigationController alloc] initWithRootViewController:rootViewController1];
    
    ChatsViewController* rootViewController2 = [[ChatsViewController alloc] init];
    UINavigationController* navigationController2 = [[UINavigationController alloc] initWithRootViewController:rootViewController2];
   
    SettingsViewController* rootViewController3 = [[SettingsViewController alloc] init];
    UINavigationController* navigationController3 = [[UINavigationController alloc] initWithRootViewController:rootViewController3];
    
    navigationController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"tab_friends"] tag:0] ;
    
    navigationController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"tab_chats"] tag:1] ;
  
    navigationController3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"tab_settings"] tag:2] ;
    
    self.tabController = [[UITabBarController alloc] init];
    self.tabController.viewControllers = [NSArray arrayWithObjects:navigationController1,navigationController2, navigationController3, nil];
    
    [self.window setRootViewController:self.tabController];
    [self.window makeKeyAndVisible];
}

-(UIViewController*) startChatWith:(NSString*) aJid withName:(NSString*) aName{
    Chat* chat = [[xmppInstance messageController] createChatForJID:aJid withDisplayName:aName];
    ChatViewController* chatView = [ChatViewController sharedViewWitChat:chat];
    return chatView;
}

@end
