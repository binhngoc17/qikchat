//
//  UIController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Chat;

@interface UIController : NSObject<UINavigationControllerDelegate>

@property(strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabController;

-(id)initWithWindow:(UIWindow *)window;
+(UIController *)getUIController;

-(void) showLoginScreen;
-(void) showMainScreen;
-(void) activateChatView:(Chat*) aChat;
-(UIViewController*) startChatWith:(NSString*) aJid withName:(NSString*) aName;
@end
