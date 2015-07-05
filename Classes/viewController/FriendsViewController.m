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

@interface FriendsViewController()
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation FriendsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self initTableView];
}

- (void) initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 46)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
    [avatarView setBackgroundColor:[UIColor clearColor]];
    avatarView.image = [Utility roundImageWithImage:[UIImage imageNamed:@"defaultAvatar.png"] borderColor:[UIColor blackColor]];
    avatarView.clipsToBounds = YES;
    [titleView addSubview:avatarView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 3, self.view.frame.size.width-120, 40)];
    titleLabel.text = [[ProfileDataManager sharedInstance] getDisplayName:nil];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    [titleLabel setFont:boldFont];
    
    if(!titleLabel.text.length){
        NSString* jid = [[ProfileDataManager sharedInstance] getXabberID:nil];
        titleLabel.text = [Utility displayName:jid];
    }
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-59, 5, 35, 35)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"add_blue.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:menuButton];
    
    self.navigationItem.titleView = titleView;

}

-(void) menuAction:(id) sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported"
                                                    message:@"Selected feature is not implemenetd!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) updateFriendList:(id) sender {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(Buddy*) abudy
{

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
	[cell setBackgroundColor:dQikAColor];
    cell.layer.borderColor = dBorderColor.CGColor;
    cell.layer.borderWidth = 1.0f;
    cell.detailTextLabel.text = budy.statusText;
    [self configurePhotoForCell:cell user:budy];
    
  	return cell;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KCustomTableRowHight50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Buddy *budy = [[xmppInstance rosterController] buddyForIndex:indexPath.row];
    if( budy ){
        UIViewController* chatview = [[UIController getUIController] startChatWith:budy.jid withName:budy.displayName];
        chatview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatview animated:NO];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
