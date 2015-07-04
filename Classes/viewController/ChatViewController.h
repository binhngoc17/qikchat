//
//  ChatViewController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 02/07/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "Chat.h"

@class Chat;

@interface ChatViewController : UIViewController <UIBubbleTableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ChatMessageDelegate>

+(ChatViewController*) sharedViewWitChat:(Chat*) achat;

@end

