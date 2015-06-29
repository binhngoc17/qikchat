//
//  FriendsViewController.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "QikAChat-Prefix.pch"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "Buddy.h"

@implementation FriendsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = NO;
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self initTableView];
}

- (void) initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [self.view addSubview:self.tableView];
    
    [self.tableView setBackgroundColor:tableColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:self.navigationBarHidden animated:YES];
    [appInstance setStatusBarHidden:self.navigationBarHidden withAnimation:UIStatusBarAnimationNone];
    
    [self initTitleSegement];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendList:) name:UPDATE_FRIEND_LIST object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_FRIEND_LIST object:nil];

    [[self navigationController] setNavigationBarHidden:false animated:YES];
    [appInstance setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
	[super viewWillDisappear:animated];
}

- (void) initTitleSegement {
    
    UIView *segmentedView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.frame.size.width, 60}];
    
    UIImageView* avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
    [avatarView setBackgroundColor:[UIColor clearColor]];
    avatarView.image = [Utility roundImageWithImage:[UIImage imageNamed:@"defaultAvatar.png"] borderColor:[UIColor blackColor]];
    avatarView.layer.cornerRadius = 3.0f;
    avatarView.clipsToBounds = YES;
    [segmentedView addSubview:avatarView];
    
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50+10, 15, self.view.frame.size.width-85, 44)];
    
     titleLabel.backgroundColor = [UIColor clearColor];
     titleLabel.textColor = [UIColor darkTextColor];
     titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
     titleLabel.numberOfLines = 1;
     titleLabel.adjustsFontSizeToFitWidth = YES;
     titleLabel.textAlignment = NSTextAlignmentCenter;
     
     if ([xmppInstance connect])
     {
         titleLabel.text = [[[xmppInstance xmppStream] myJID] bare];
     } else
     {
         titleLabel.text = @"No JID";
     }
     [titleLabel sizeToFit];
    
     [segmentedView addSubview:titleLabel];
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 10, 35, 35)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"navmenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [segmentedView addSubview:menuButton];
  
    self.navigationItem.titleView = segmentedView;
    
}

-(void) menuAction:(id) sender{
    
}
-(void) updateFriendList:(id) sender {
    [self.tableView reloadData];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(Buddy*) abudy
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (abudy.avatarImage != nil)
	{
		cell.imageView.image = [Utility roundImageWithImage:abudy.avatarImage borderColor:[UIColor blackColor]];
   }
	else
	{
        cell.imageView.image = [Utility roundImageWithImage:[UIImage imageNamed:@"defaultAvatar"] borderColor:[UIColor blackColor]];
	}
    
    cell.imageView.layer.cornerRadius = 3.0f;
    cell.imageView.clipsToBounds = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[ xmppInstance rosterController ] rosterCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
		                               reuseIdentifier:CellIdentifier];
 	}
	
    Buddy *budy = [[xmppInstance rosterController] buddyForIndex:indexPath.row];
	cell.textLabel.text = budy.displayName;
	[cell setBackgroundColor:tableCellColor];
    cell.layer.borderColor = headerColor.CGColor;
    cell.layer.borderWidth = 1.0f;
    cell.detailTextLabel.text = budy.statusText;
    [self configurePhotoForCell:cell user:budy];
    
  	return cell;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)settings:(id)sender
{
	//[self.navigationController presentViewController:[app settingsViewController] animated:YES completion:NULL];
}

@end
