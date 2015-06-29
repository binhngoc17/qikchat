//
//  ProfileDataManager.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Literals.h"

@interface ProfileDataManager : NSObject

+(ProfileDataManager *)sharedInstance;

- (void) commitChange;

/*
 *has CreatedAccount launch
 */
-(BOOL)hasCreatedAccount;
-(void)setHasCreatedAccount:(BOOL)isFirstLaunch;


/*
 *is account verified
 */

-(BOOL)isAccountVerified;
-(void)accountVerified:(BOOL)accountVerified;


/*
 *Xabber ID
 */

-(NSString *)getXabberID:(NSString *)string;
-(void)setXabberID:(NSString *)xabberID;

-(void)setMyPhoneNumber:(NSDictionary *)phoneDict;
-(NSDictionary *)getMyPhoneNumber;


/*is phone verified*/
-(BOOL)isPhoneVerified;
-(void)phoneVerified:(BOOL)phoneVerified;

/*getter and setter for display name*/
-(NSString *)getDisplayName:(NSString *)name ;
-(void)setDisplayName:(NSString *)name;


/*email verified*/
-(BOOL)isEmailVerified;
-(void)emailVerified:(BOOL)isVerified;


/*email id*/
-(NSString *)getEmailID:(NSString *)emailID;
-(void)setEmailId:(NSString *)emailID;

/*password*/
-(NSString *)getPassword:(NSString*)password;
-(void)setPassword:(NSString *)password;

/*getter and setter for avatar*/
-(UIImage *)getMyAvatarImage;
-(void)setMyAvatarImage:(NSData *)aImageData;

/*license agreed*/
-(BOOL)isLicenseAgreed;
-(void)licenseIsAgreed;


-(void)setToken:(NSString *)token;
-(NSString *)getToken;

-(NSString *)getDatabaseVersion;
-(void )setDatabaseVersion:(NSString*) aVersion;

/*email verified*/
-(BOOL)isAddressBookUploaded;
-(void)setAddressbookUploaded:(BOOL)isVerified;

-(void)setChatId:(NSString *)chatId;
-(NSString*)getChatID:(NSString *)temp;

-(BOOL)isMessageVibrateChecked;
-(void)setMessageVibrate:(BOOL)value;
-(BOOL)isMessageToneOn;
-(void)setMessageTone:(BOOL)value;

-(void)setPasscode:(NSString *)value;
-(NSString *)getPasscode;

@end
