//
//  Utility.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 27/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QikAChat-Prefix.pch"

@interface Utility : NSObject

+ (UIImage *)roundImageWithImage:(UIImage *)image borderColor:(UIColor *)borderColor;

+(NSString *) dateToString:(NSDate *) date withFormat:(NSString *) format ;
+(NSDate *) stringToDate:(NSString *) stamp withFormat:(NSString *) format;
+(NSString *) timeToShortStringForDisplay:(NSDate *) date;

+ (NSString *) contentTypeForImageData:(NSData *)data;
+ (NSString *)relativeDateStringForDate:(NSDate *)date;
+ (NSString*) getTimestampForDate:(NSDate*)date;
+ (NSString*) getTimestampForChat:(NSDate*)date;

+(BOOL)isDisplayNameValid:(NSString*)aName;
+(NSString*)displayName:(NSString*)aJID;
+(NSString*)bareJID:(NSString*)aNumber;
+(NSString*)bareXabberJID:(NSString*)aNumber;


@end
