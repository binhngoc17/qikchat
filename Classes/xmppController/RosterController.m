//
//  RosterController.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 28/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "RosterController.h"
#import "QikAChat-Prefix.pch"
#import "StorageManager.h"
#import "Buddy.h"

@implementation RosterController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(id) initWithStream:(XMPPStream*) xmppStream
{
    self = [super init];
    
    if(self)
    {
        _xmppStream = xmppStream;
        [self setup];
    }
    return self;
}

- (void) setup
{
    _allBuddyList  = [[NSMutableDictionary alloc] init];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
    xmppRoster.autoClearAllUsersAndResources = NO;
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Activate Roster modules
    [xmppRoster            activate:_xmppStream];
    [xmppvCardTempModule   activate:_xmppStream];
    [xmppvCardAvatarModule activate:_xmppStream];
    
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue() ];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[StorageManager  sharedInstance] loadAllRosters:_allBuddyList];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FRIEND_LIST object:self];
    });
}

/*
 *call it in delloc of to tear down connection
 */
- (void)teardown
{
    [xmppRoster removeDelegate:self];
    [xmppvCardTempModule removeDelegate:self];
    [xmppvCardAvatarModule removeDelegate:self];
    
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

-(void)handleServiceAuthenticated{
    
    [self fetchRosterList:nil];
}

-(void)handleReceivePresence:(XMPPPresence*) presence{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:_xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - xmppvCardTempModuleDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPvCardAvatarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if TARGET_OS_IPHONE
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
              didReceivePhoto:(UIImage *)photo
                       forJID:(XMPPJID *)jid{
    
}
#else
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
              didReceivePhoto:(NSImage *)photo
                       forJID:(XMPPJID *)jid{
    
}
#endif


- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [self managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
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

-(void) fetchRosterList:(NSString*) aJid
{
    BOOL updated = false;
    NSFetchedResultsController *frc = [self fetchedResultsController];
    NSArray *sections = [[self fetchedResultsController] sections];
    NSUInteger sectionsCount = [[[self fetchedResultsController] sections] count];
    
    for(int sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        NSString *sectionName;
        OTRBuddyStatus otrBuddyStatus;
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  :
                sectionName = @"Available";
                otrBuddyStatus = kOTRBuddyStatusAvailable;
                break;
            case 1  :
                sectionName = @"Away";
                otrBuddyStatus = kOTRBuddyStatusAway;
                break;
            default :
                sectionName = @"Offline";
                otrBuddyStatus = kOTRBuddyStatusOffline;
                break;
        }
        
        for(int j = 0; j < sectionInfo.numberOfObjects; j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:sectionIndex];
            XMPPUserCoreDataStorageObject *user = [frc objectAtIndexPath:indexPath];
            
            [xmppvCardTempModule fetchvCardTempForJID:user.jid ignoreStorage:YES];
            
            
            NSString* displayName = user.displayName;
            if(![Utility isDisplayNameValid:displayName ] && user.nickname )
                displayName = user.nickname;
            
            NSString* subscribtion = user.subscription;
            NSString* bareJid = [[user jid] bare];
            
            updated = updated || [self handleRosterItemUpdate:bareJid subcribtion:subscribtion formatName:displayName];
            Buddy *buddy = [_allBuddyList objectForKey:bareJid];
            if( buddy )
            {
                buddy.buddyStatus = otrBuddyStatus;
                buddy.groupName = sectionName;
                if (user.photo != nil)
                {
                    buddy.avatarImage  = user.photo;
                    updated = YES;
                }
                else
                {
                    NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
                    if (photoData != nil) {
                        UIImage *avtImg = [UIImage imageWithData:photoData];
                        buddy.avatarImage = avtImg;
                        updated = YES;
                    }
                }
                //  if image availabe set , other wise request for image
            }
            else
            {
                Buddy *buddy = [[Buddy alloc] initWithDisplayName:displayName accountJid:bareJid status:otrBuddyStatus groupName:sectionName];
                [_allBuddyList setObject:buddy forKey:bareJid];
                
                if (user.photo != nil)
                {
                    buddy.avatarImage  = user.photo;
                    updated = YES;
                }
                else
                {
                    NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
                    if (photoData != nil) {
                        UIImage *avtImg = [UIImage imageWithData:photoData];
                        buddy.avatarImage = avtImg;
                    }
                }
                
                [[StorageManager sharedInstance] saveNewRoster:buddy];
            }
            
        }
    }
    
    if( updated ){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[StorageManager  sharedInstance] updateRosters:_allBuddyList.allValues];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FRIEND_LIST object:self];
        });
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
    NSFetchedResultsController *frc = [self fetchedResultsController];
    BOOL updated = false;
    NSString *sectionName;
    OTRBuddyStatus otrBuddyStatus;
    
    int section = [sectionInfo.name intValue];
    switch (section)
    {
        case 0  :
            sectionName = @"Available";
            otrBuddyStatus = kOTRBuddyStatusAvailable;
            break;
        case 1  :
            sectionName = @"Away";
            otrBuddyStatus = kOTRBuddyStatusAway;
            break;
        default :
            sectionName = @"Offline";
            otrBuddyStatus = kOTRBuddyStatusOffline;
            break;
    }
    
    for(int j = 0; j < sectionInfo.numberOfObjects; j++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:sectionIndex];
        XMPPUserCoreDataStorageObject *user = [frc objectAtIndexPath:indexPath];
        
        [xmppvCardTempModule fetchvCardTempForJID:user.jid ignoreStorage:YES];
        
        NSString* displayName = user.displayName;
        if(![Utility isDisplayNameValid:displayName ] && user.nickname )
            displayName = user.nickname;
        
        NSString* subscribtion = user.subscription;
        NSString* bareJid = [[user jid] bare];
        
        updated = updated || [self handleRosterItemUpdate:bareJid subcribtion:subscribtion formatName:displayName];
        Buddy *buddy = [_allBuddyList objectForKey:bareJid];
        if( buddy )
        {
            buddy.buddyStatus = otrBuddyStatus;
            buddy.groupName = sectionName;
            if (user.photo != nil)
            {
                buddy.avatarImage  = user.photo;
                updated = YES;
            }
            else
            {
                NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
                if (photoData != nil) {
                    UIImage *avtImg = [UIImage imageWithData:photoData];
                    buddy.avatarImage = avtImg;
                    updated = YES;
                }
            }
            if( updated )
                [[StorageManager sharedInstance] updateRosterAvatar:buddy];
        }
        else
        {
            Buddy *buddy = [[Buddy alloc] initWithDisplayName:displayName accountJid:bareJid status:otrBuddyStatus groupName:sectionName];
            [_allBuddyList setObject:buddy forKey:bareJid];
            if (user.photo != nil)
            {
                buddy.avatarImage  = user.photo;
            }
            else
            {
                NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
                if (photoData != nil) {
                    UIImage *avtImg = [UIImage imageWithData:photoData];
                    buddy.avatarImage = avtImg;
                }
            }
            [[StorageManager sharedInstance] saveNewRoster:buddy];
        }
    }
    
    if( updated ){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[StorageManager  sharedInstance] updateRosters:_allBuddyList.allValues];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FRIEND_LIST object:self];
        });
    }
}

-(BOOL) handleRosterItemUpdate:(NSString*) aJID subcribtion:(NSString*) subscribe formatName:(NSString*) name
{
    BOOL didFrindChanged = NO;
    
    if( [subscribe isEqualToString:@"to"] ||  [subscribe isEqualToString:@"both"] || [subscribe isEqualToString:@"none"])
    {
        Buddy *buddy = [_allBuddyList objectForKey:aJID];
        if(!buddy)
        {
            buddy = [Buddy buddyWithDisplayName:name accountJid:aJID status:kOTRBuddyStatusOffline groupName:nil];
            [_allBuddyList setObject:buddy forKey:aJID];
            buddy.currentStatusText = @"";
            didFrindChanged = YES;
            [[StorageManager sharedInstance] saveNewRoster:buddy];
           // [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_FRIEND_LIST object:self];
        }
        else if( [name length] && ![name isEqualToString:[buddy getDisplayName]])
        {
            [buddy setBuddyDisplayName:name]; // update new name
            didFrindChanged = YES;
        }
    }
    else if( [subscribe isEqualToString:@"from"] )
    {
        Buddy* budy = [_allBuddyList objectForKey:aJID];
        if( _allBuddyList && budy  )
        {
            [[StorageManager sharedInstance] removeRoster:budy];
            [_allBuddyList removeObjectForKey:aJID];
            didFrindChanged = YES;
        }
    }
    else if( [subscribe isEqualToString:@"remove"])
    {
        didFrindChanged = YES;
        
        Buddy* buddy = [_allBuddyList objectForKey:aJID];
        if( buddy ){
            [[StorageManager sharedInstance] removeRoster:buddy];
            [_allBuddyList removeObjectForKey:aJID];
        }
    }
    
    return didFrindChanged;
}


-(Buddy*) getBuddyForJId:(NSString*) aJID
{
    if( [_allBuddyList count ] )
    {
        Buddy *buddy = [_allBuddyList objectForKey:aJID];
        if( !buddy )
        {
            NSString* fullJid = [NSString stringWithFormat:@"%@@%@",aJID, QIKACHAT_DOMAIN_NAME];
            buddy = [_allBuddyList objectForKey:fullJid];
        }
        return buddy;
    }
    
    return nil;
}

-(Buddy*) buddyForIndex:(NSInteger) aIndex{
   
    return [[_allBuddyList allValues] objectAtIndex:aIndex];
}

-(NSInteger) rosterCount
{
    return _allBuddyList.count;
}

@end
