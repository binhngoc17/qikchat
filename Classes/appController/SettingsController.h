//
//  SettingsController.h
//
//  Created by Ram Bhawan Chauhan on 07/08/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface SettingsController : NSObject

+(SettingsController *)sharedInstance;

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

/*theme setter getter*/
-(NSString *)getThemeName;
-(void)setTheme:(NSString *)plistName;

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


-(void)setChatnaId:(NSString *)chatnaId;
-(NSString*)getChatnaID:(NSString *)temp;

-(BOOL)isMessageVibrateChecked;
-(void)setMessageVibrate:(BOOL)value;
-(BOOL)isMessageToneOn;
-(void)setMessageTone:(BOOL)value;


-(void)setPasscode:(NSString *)value;
-(NSString *)getPasscode;


-(void)setChatTextSize:(NSInteger)sizeVal;
-(ChatTextSize)getChatTextSize;

@end
