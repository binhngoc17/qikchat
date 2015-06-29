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


@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property(strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) IBOutlet UITabBarController *tabController;
@property (nonatomic, strong) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;

@end
