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

@interface RosterController : NSObject<XMPPRosterDelegate,XMPPvCardTempModuleDelegate,XMPPvCardAvatarDelegate, NSFetchedResultsControllerDelegate>
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

-(id) initWithStream:(XMPPStream*) xmppStream;
-(void)teardown;

-(void)handleServiceAuthenticated;
-(void)handleReceivePresence:(XMPPPresence*) presence;

- (NSManagedObjectContext *)managedObjectContext_roster;

-(Buddy*) buddyForIndex:(NSInteger) aIndex;
-(NSInteger) rosterCount;
-(Buddy*) getBuddyForJId:(NSString*) aJID;
@end
