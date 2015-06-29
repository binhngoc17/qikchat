//
//  SettingsController.m
//
//  Created by Ram Bhawan Chauhan on 07/08/14.
//  Copyright (c) 2014 CraterZone. All rights reserved.
//

#import "SettingsController.h"
#import "Literals.h"

@implementation SettingsController

NSString *const HAS_CREATED_ACCOUNT = @"HAS_CREATED_ACCOUNT";
NSString *const IS_ACCOUNT_VERIFIED = @"IS_ACCOUNT_VERIFIED";
NSString *const XABBER_ID = @"XABBER_ID";
NSString *const PHONE_NUMBER = @"PHONE_NUMBER";
NSString *const PHONE_VERIFIED = @"PHONE_VERIFIED";
NSString *const DISPLAY_NAME = @"DISPLAY_NAME";
NSString *const EMAIL_VERIFIED = @"EMAIL_VERIFIED";
NSString *const EMAIL_ID = @"EMAIL_ID";
NSString *const PASSWORD_KEY = @"PASSWORD_KEY";
NSString *const THEME_KEY = @"THEME_KEY";
NSString *const MY_AVATAR_KEY = @"MY_AVATAR_KEY";
NSString *const LICENSE_AGREED = @"LICENSE_AGREED";
NSString *const TOKEN_KEY = @"TOKEN_KEY";
NSString *const KDATABASE_VERSION =@"DATABASE_VERSION";
NSString *const KACONTACT_UPLOADED =@"CONTACT_UPLOADED";
NSString *const CHAT_ID_KEY = @"CHAT_ID_KEY";
NSString *const MESSAGE_VIBRATE_KEY = @"MESSAGE_VIBRATE_KEY";
NSString *const MESSAGE_TONE_KEY = @"MESSAGE_TONE_KEY";
NSString *const PASSCODE_KEY = @"PASSCODE_KEY";
NSString *const TEXT_SIZE_KEY = @"TEXT_SIZE_KEY";

+(SettingsController *)sharedInstance
{
    static SettingsController *sharedManager;
    @synchronized(self)
    {
        if (sharedManager == nil) {
            sharedManager = [[SettingsController alloc] init];
            
        }
        return sharedManager;
    }
}

- (void) commitChange
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - has created account
-(BOOL)hasCreatedAccount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:HAS_CREATED_ACCOUNT];
}


-(void)setHasCreatedAccount:(BOOL)isFirstLaunch {
    
    
    [[NSUserDefaults standardUserDefaults] setBool:isFirstLaunch forKey:HAS_CREATED_ACCOUNT];
}

#pragma mark - is account verified
-(BOOL)isAccountVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:IS_ACCOUNT_VERIFIED];
}


-(void)accountVerified:(BOOL)accountVerified {
    
    [[NSUserDefaults standardUserDefaults] setBool:accountVerified forKey:IS_ACCOUNT_VERIFIED];
}





-(NSString *)getXabberID:(NSString *)string {
    NSString *xabberID = [[NSUserDefaults standardUserDefaults] valueForKey:XABBER_ID];
    
    if (xabberID) {
        return xabberID;
    }
    return string;
}



-(void)setXabberID:(NSString *)xabberID {
    
    [[NSUserDefaults standardUserDefaults] setValue:xabberID forKeyPath:XABBER_ID];
}


/*set my phone number*/
-(void)setMyPhoneNumber:(NSDictionary *)phoneDict {
    [[NSUserDefaults standardUserDefaults] setObject:phoneDict forKey:PHONE_NUMBER];
}

/*get my phone number*/
-(NSDictionary *)getMyPhoneNumber {
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:PHONE_NUMBER];
    return [NSDictionary dictionaryWithDictionary:dict];
}


-(BOOL)isPhoneVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PHONE_VERIFIED];
}


-(void)phoneVerified:(BOOL)phoneVerified {
    [[NSUserDefaults standardUserDefaults] setBool:phoneVerified forKey:PHONE_VERIFIED];
    
}



/*getter and setter for display name*/
-(NSString *)getDisplayName:(NSString *)name  {
    NSString *displayName = [[NSUserDefaults standardUserDefaults] valueForKey:DISPLAY_NAME];
    if (displayName) {
        return displayName;
    }
    return name;


}
-(void)setDisplayName:(NSString *)name {
    if (name != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:DISPLAY_NAME];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DISPLAY_NAME];
    }
    
}


/*email verified*/
-(BOOL)isEmailVerified {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:EMAIL_VERIFIED];
    
}
-(void)emailVerified:(BOOL)isVerified {
    
    [[NSUserDefaults standardUserDefaults] setBool:isVerified forKey:EMAIL_VERIFIED];
    
}


/*email id*/
-(NSString *)getEmailID:(NSString *)emailID {
    NSString *emailid = [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL_ID];
    if (emailid) {
        return emailid;
    }
    return emailID;


}
-(void)setEmailId:(NSString *)emailID {
    if (emailID != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:emailID forKey:EMAIL_ID];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMAIL_ID];
    }
}

/*password*/
-(NSString *)getPassword:(NSString*)password {
    NSString *userDefaultPassword = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD_KEY];
    if (userDefaultPassword) {
        return userDefaultPassword;
    }
    return password;
}
-(void)setPassword:(NSString *)password {
    if (password != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD_KEY];
    }
}

-(UIImage *)getMyAvatarImage {
    NSData *myAvatarData = [[NSUserDefaults standardUserDefaults] valueForKey:MY_AVATAR_KEY];
    if (myAvatarData) {
        return [UIImage imageWithData:myAvatarData];
    }
    return nil;
}

-(void)setMyAvatarImage:(NSData *)aImageData{
    if (aImageData != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:aImageData forKey:MY_AVATAR_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:MY_AVATAR_KEY];
    }
}

-(BOOL)isLicenseAgreed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:LICENSE_AGREED];
}


-(void)licenseIsAgreed {
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:LICENSE_AGREED];
    [self commitChange];
}

-(void)setToken:(NSString *)token {
    if (token != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:TOKEN_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN_KEY];
    }
}

-(NSString *)getToken {
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:TOKEN_KEY];
    
}

-(NSString *)getDatabaseVersion {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KDATABASE_VERSION];
}

-(void )setDatabaseVersion:(NSString*) aVersion
{
    if (aVersion != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:aVersion forKey:KDATABASE_VERSION];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KDATABASE_VERSION];
    }
}

-(BOOL)isAddressBookUploaded
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:KACONTACT_UPLOADED];
}
-(void)setAddressbookUploaded:(BOOL)aValue
{
    [[NSUserDefaults standardUserDefaults] setBool:aValue forKey:KACONTACT_UPLOADED];
}

-(void)setChatId:(NSString *)chatId {
    if (chatId != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:chatId forKey:CHAT_ID_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHAT_ID_KEY];
    }
}

-(NSString *)getChatID:(NSString *)temp {
    NSString *chatid = [[NSUserDefaults standardUserDefaults] objectForKey:CHAT_ID_KEY];
    return ((chatid != nil)?chatid:temp);
}


-(BOOL)isMessageVibrateChecked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_VIBRATE_KEY];
    
}

-(void)setMessageVibrate:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:MESSAGE_VIBRATE_KEY];
}


-(BOOL)isMessageToneOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:MESSAGE_TONE_KEY];
    
}

-(void)setMessageTone:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:MESSAGE_TONE_KEY];
}

-(void)setPasscode:(NSString *)value {
    if (value != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:PASSCODE_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSCODE_KEY];
    }
    
}
-(NSString *)getPasscode {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PASSCODE_KEY];
}

@end
