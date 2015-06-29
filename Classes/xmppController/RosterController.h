//
//  xmppRosterController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 28/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QikAChat-Prefix.pch"

@interface XmppRosterController : NSObject<NSFetchedResultsControllerDelegate>
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
- (void)teardown;
- (NSManagedObjectContext *)managedObjectContext_roster;

-(NSInteger) rosterCount:(NSInteger) sectionIndex;
-(XMPPUserCoreDataStorageObject*) userForPath:(NSIndexPath*) indexPath;

@end
