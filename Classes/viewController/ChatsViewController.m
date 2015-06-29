//
//  ChatsViewController.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "ChatsViewController.h"
#import "SettingsViewController.h"
#import "QikAChat-Prefix.pch"
#import "Chat.h"

@implementation ChatsViewController

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
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatList:) name:UPDATE_CHAT_LIST object:nil];

    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_CHAT_LIST object:nil];

    [[self navigationController] setNavigationBarHidden:false animated:YES];
    [appInstance setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
	[super viewWillDisappear:animated];
}


- (void) initTitleSegement {
    
    UIView *segmentedView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.frame.size.width, 60}];
    
   
    UIButton* plusButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
    [plusButton setBackgroundImage:[UIImage imageNamed:@"navmenu"] forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [segmentedView addSubview:plusButton];
  
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, self.view.frame.size.width-85, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Chats";
    
    
    [segmentedView addSubview:titleLabel];
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 10, 35, 35)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"navmenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [segmentedView addSubview:menuButton];
    
    self.navigationItem.titleView = segmentedView;
    
}

-(void) menuAction:(id) sender{
    
}

-(void) updateChatList:(id) sender {
    
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(Buddy *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    if (user.avatarImage != nil)
    {
        cell.imageView.image = [Utility roundImageWithImage:user.avatarImage borderColor:[UIColor blackColor]];
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
  	return [[xmppInstance messageController] chatCount];
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
    
    Chat* chat = [[xmppInstance messageController] chatForIndex:indexPath.row];
    Buddy *user = [[xmppInstance rosterController] getBuddyForJId:chat.chatJid];
    
    if( user != nil && [user displayName].length )
        cell.textLabel.text = [user displayName];
    else
        cell.textLabel.text = chat.chatJid;

    cell.detailTextLabel.text = chat.lastMessage;
   
	[self configurePhotoForCell:cell user:user];
	
    [cell setBackgroundColor:tableCellColor];
    cell.layer.borderColor = headerColor.CGColor;
    cell.layer.borderWidth = 1.0f;

    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)settings:(id)sender
{
	//[self.navigationController presentViewController:[[self appDelegate] settingsViewController] animated:YES completion:NULL];
}

@end
