//
//  ChatsViewController.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "ChatsViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "QikAChat-Prefix.pch"
#import "XMPPFramework.h"
#import "DDLog.h"

#import "XMPPCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPMessageArchiving_Contact_CoreDataObject.h"


// Log levels: off, error, warn, info, verbose
#if DEBUG
  static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
  static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation ChatsViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self fetchedResultsController];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
  
    [[self navigationController] setNavigationBarHidden:self.navigationBarHidden animated:YES];
    [appInstance setStatusBarHidden:self.navigationBarHidden withAnimation:UIStatusBarAnimationNone];
    
    self.title = @"Chats";
    
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:false animated:YES];
    [appInstance setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
	[[self appDelegate] disconnect];
	[[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
	
	[super viewWillDisappear:animated];
}



-(void) segmentedControlDidChange{
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
        
        
    	NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_message];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
		
		NSArray *sortDescriptors = @[sd1];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
	
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    
    if (user.photo != nil)
    {
        cell.imageView.image = [Utility roundImageWithImage:user.photo borderColor:[UIColor blackColor]];
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [Utility roundImageWithImage:[UIImage imageWithData:photoData] borderColor:[UIColor blackColor]];
        else
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
    return 1; //[[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
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
    
    XMPPMessageArchiving_Contact_CoreDataObject *chat = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    XMPPUserCoreDataStorageObject *user =[[self appDelegate] managedObjectContext_forUser:chat.bareJid];
    
    if( user != nil && [user displayName].length )
        cell.textLabel.text = [user displayName];
    else
        cell.textLabel.text = chat.bareJidStr;

    cell.detailTextLabel.text = chat.mostRecentMessageBody;
   
	[self configurePhotoForCell:cell user:user];
	
	return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)settings:(id)sender
{
	[self.navigationController presentViewController:[[self appDelegate] settingsViewController] animated:YES completion:NULL];
}

@end
