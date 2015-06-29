//
//  RosterController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 28/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "XMPPFramework.h"
#import "Buddy.h"

#define UPDATE_FRIEND_LIST  @"friendupdateNotification"

@class Buddy;

@interface RosterController : NSObject<NSFetchedResultsControllerDelegate>
{
     NSFetchedResultsController *fetchedResultsController;

    XMPPStream *_xmppStream;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPRoster *xmppRoster;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    NSMutableDictionary *_allBuddyList;
}

-(void)handleServiceAuthenticated;
-(id) initWithStream:(XMPPStream*) xmppStream;
- (void)teardown;

- (NSManagedObjectContext *)managedObjectContext_roster;

-(Buddy*) buddyForIndex:(NSInteger) aIndex;
-(NSInteger) rosterCount;
-(Buddy*) getBuddyForJId:(NSString*) aJID;
@end
