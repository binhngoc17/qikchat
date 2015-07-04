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

@interface ChatsViewController()
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation ChatsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self initTableView];
    
}

- (void) initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [self.view addSubview:self.tableView];
    
    [self.tableView setBackgroundColor:dClearColor];

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
  
    self.navigationController.navigationBar.translucent = YES;
    
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
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"navmenu.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
 
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:menuButton ];
    
    self.title = @"Chats";
    
    UIButton* addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 10, 35, 35)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"add_blue.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:addButton ];
    
}

-(void) menuAction:(id) sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported"
                                                    message:@"Selected feature is not implemenetd!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) addAction:(id) sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported"
                                                    message:@"Selected feature is not implemenetd!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) updateChatList:(id) sender {
    
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(Buddy *)user
{
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
	
    [cell setBackgroundColor:dTableCellColor];
    cell.layer.borderColor = dHeaderColor.CGColor;
    cell.layer.borderWidth = 1.0f;

    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Chat *chat = [[xmppInstance messageController] chatForIndex:indexPath.row];
    if( chat ){
        UIViewController* chatview = [[UIController getUIController] startChatWith:chat.chatJid withName:[chat getDisplayName]];
        chatview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatview animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
