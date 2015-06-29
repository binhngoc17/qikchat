//
//  Buddy.m
//  ChatNa
//
//  Created by Babul Prabhakar on 29/07/14.
//  Copyright (c) 2014 Babul Prabhakar. All rights reserved.
//

#import "Buddy.h"
#import "DDXMLElement.h"
#import "XmppController.h"
#import "Strings.h"
#import "DDLog.h"
#import "QikAChat-Prefix.pch"

@implementation Buddy
@synthesize groupName;
@synthesize encryptionStatus;
@synthesize avatarImage;
@synthesize isABContact;
@synthesize hresAvtarURL;
@synthesize displayName;
@synthesize lresAvtarURL;
@synthesize lastSeenDate;

-(id)initWithDisplayName:(NSString*)buddyName accountName:(NSString*) buddyAccountName status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    if(self = [super init])
    {
        self.accountName = buddyAccountName;
        self.buddyStatus = buddyStatus;
        self.groupName = buddyGroupName;
        [self setBuddyDisplayName:buddyName];
        self.phoneNumer = @"";
        self.hresAvtarURL = @""; // do not change it
        self.statusText = @"Whatsup";
        _isLastSeenFetched = FALSE;
    }
    return self;
}

+(Buddy*)buddyWithDisplayName:(NSString*)buddyName accountName:(NSString*) accountName  status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    Buddy *newBuddy = [[Buddy alloc] initWithDisplayName:buddyName accountName:accountName  status:buddyStatus groupName:buddyGroupName];
    return newBuddy;
}

-(void) setBuddyDisplayName:(NSString*) aDisplayName
{
    NSRange atRange = [aDisplayName rangeOfString:[NSString stringWithFormat:@"@%@",QIKACHAT_DOMAIN_NAME]];
    if (atRange.location == NSNotFound && aDisplayName.length )
    {
        displayName = aDisplayName; // replace state away
    }
    else if( aDisplayName.length && displayName == nil )
    {
        displayName = [aDisplayName substringToIndex:atRange.location];
    }
}

-(NSString*) getDisplayName
{
    if(displayName)
        return displayName;
    
    return [Utility displayName:self.accountName];
}

-(void) setPhoneNumber:(NSString*) aNumber
{
    NSRange atRange = [aNumber rangeOfString:@"@"];
    if (atRange.location != NSNotFound)
    {
        self.phoneNumer = [aNumber substringToIndex:atRange.location];
    }
    else{
        self.phoneNumer = aNumber;
    }
}

-(void) setCurrentStatusText:(NSString *)aCurrentStatusText
{
    if( [aCurrentStatusText length] )
        self.statusText = aCurrentStatusText;
}

-(void) setCurrentStatus:(OTRBuddyStatus)newStatus
{
    if( newStatus == kOTRBuddyStatusAway )
    {
        self.lastSeenDate = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    else if( newStatus == kOTRBuddyStatusAvailable )
    {
        self.lastSeenDate = nil;
    }
    self.buddyStatus = newStatus;
    
}

-(void)receiveStatusMessage:(NSString *)message
{
    if (message) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
    }
}

-(void)receiveEncryptionMessage:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
    
}

-(void)setEncryptionStatus:(OTRKitMessageState)newEncryptionStatus
{
    if( newEncryptionStatus != kOTRKitMessageStateEncrypted)
    {
        [self receiveEncryptionMessage:CONVERSATION_NOT_SECURE_WARNING_STRING];
    }
    else if(newEncryptionStatus != self.encryptionStatus)
    {
        if (newEncryptionStatus != kOTRKitMessageStateEncrypted && encryptionStatus == kOTRKitMessageStateEncrypted) {
            [[[UIAlertView alloc] initWithTitle:SECURITY_WARNING_STRING message:[NSString stringWithFormat:CONVERSATION_NO_LONGER_SECURE_STRING, [self getDisplayName]] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil] show];
        }
        switch (newEncryptionStatus) {
            case kOTRKitMessageStatePlaintext:
                [self receiveEncryptionMessage:CONVERSATION_NOT_SECURE_WARNING_STRING];
                break;
            case kOTRKitMessageStateEncrypted:
                [self receiveEncryptionMessage:CONVERSATION_SECURE_WARNING_STRING];
                break;
            case kOTRKitMessageStateFinished:
                [self receiveEncryptionMessage:CONVERSATION_NOT_SECURE_WARNING_STRING];
                break;
            default:
                DDLogVerbose(@"Unknown Encryption State");
                break;
        }
        
    }
    encryptionStatus = newEncryptionStatus;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTREncryptionStateNotification object:self];
}

-(void) setABLUID:(int) luid
{
    _associatedluid = luid;
}
-(int) getABLUID
{
    return _associatedluid;
}

-(OTRBuddyStatus) getStatus
{
    return self.buddyStatus;
}

//for showing phone number on contact list  method  --babul
-(NSString *)getPhoneNumer {
    return [Utility displayName:self.accountName];
}

-(void) setLastSeenFetched:(BOOL) aValue
{
    _isLastSeenFetched = aValue;
}

-(BOOL) isLastSeenFetched
{
    return _isLastSeenFetched;
}

@end
