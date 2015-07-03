//
//  Buddy.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef unsigned int OTRKitMessageState;

enum OTRKitMessageState { // OtrlMessageState
    kOTRKitMessageStatePlaintext = 0, //OTRL_MSGSTATE_PLAINTEXT
    kOTRKitMessageStateEncrypted = 1, // OTRL_MSGSTATE_ENCRYPTED
    kOTRKitMessageStateFinished = 2 // OTRL_MSGSTATE_FINISHED
}; //

enum OTRBuddyStatus {
    kOTRBuddyStatusAvailable = 0,
    KOTRChatStatusBusy = 1,
    kOTRBuddyStatusAway = 2,
    kOTRBuddyStatusDreaming = 3,
    kOTRBuddyStatusBroken= 4,
    kOTRBuddyStatusAnnoyed = 5,
    kOTRBuddyStatusLazy = 6,
    kOTRBuddyStatusOffline = 7
};
typedef unsigned int OTRBuddyStatus;

#define MESSAGE_PROCESSED_NOTIFICATION @"MessageProcessedNotification"
#define kOTREncryptionStateNotification @"kOTREncryptionStateNotification"

@interface Buddy : NSObject
{
    int _associatedluid;
    BOOL _isLastSeenFetched;
}

@property (nonatomic, retain, getter = getJid ) NSString* jid;
@property (nonatomic, retain) NSString* groupName;
@property (nonatomic, retain, getter = getCurrentStatusText ) NSString *statusText;
@property (nonatomic, retain) UIImage *avatarImage;
@property (nonatomic, retain, getter = getPhoneNumer) NSString * phoneNumer;
@property (nonatomic, assign) BOOL isABContact;
@property (nonatomic, strong) NSString* hresAvtarURL;
@property (nonatomic, strong) NSString* displayName;
@property (nonatomic) OTRBuddyStatus buddyStatus;
@property (nonatomic) OTRKitMessageState encryptionStatus;
@property (nonatomic, strong) NSString* lresAvtarURL;
@property (nonatomic, strong) NSDate *lastSeenDate;

-(id)initWithDisplayName:(NSString*)buddyName accountJid:(NSString*)accountName status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName;
+(Buddy*)buddyWithDisplayName:(NSString*)buddyName accountJid:(NSString*)accountName  status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName;

-(void) setBuddyDisplayName:(NSString*) aDisplayName;
-(NSString*) getDisplayName;
-(void) setPhoneNumber:(NSString*) aNumber;
-(void) setCurrentStatusText:(NSString *)newStatusText;
-(void) setCurrentStatus:(OTRBuddyStatus)newStatus;
-(void) setABLUID:(int) luid;
-(int) getABLUID;
-(OTRBuddyStatus) getStatus;
-(BOOL) isLastSeenFetched;
-(void) setLastSeenFetched:(BOOL) aValue;

@end