//
//  ChatViewController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 02/07/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
@class Chat;

@interface ChatViewController : UIViewController <UIBubbleTableViewDataSource,UITableViewDelegate>

@property(nonatomic) BOOL navigationBarHidden;
@property(nonatomic, strong) Chat* currentChat;
@property(nonatomic) BOOL isReloadTabble;

-(void) setupChat:(Chat*) newChat;

@end

