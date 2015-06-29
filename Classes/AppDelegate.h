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

@class Chat;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property(strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) IBOutlet UITabBarController *tabController;

-(void) activateChatView:(Chat*) aChat;

@end
