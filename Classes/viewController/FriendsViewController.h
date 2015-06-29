//
//  FriendsViewController.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface FriendsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>


@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic) BOOL navigationBarHidden;

- (IBAction)settings:(id)sender;

@end
