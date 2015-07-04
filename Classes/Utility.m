//
//  Utility.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 27/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "Utility.h"
#import "NSBubbleData.h"
#import "Message.h"

@implementation Utility


+ (UIImage *)roundImageWithImage:(UIImage *)image borderColor:(UIColor *)borderColor
{
    UIImage *retImage = nil;
    
    retImage = [Utility roundImageWithImage:image scale:image.scale borderColor:borderColor];
    
    return retImage;
}

+ (UIImage *)roundImageWithImage:(UIImage *)image scale:(CGFloat)scale borderColor:(UIColor *)borderColor
{
    UIImage *retImage = nil;
    
    CGSize imageSize = image.size;
    
    if (imageSize.width > imageSize.height)
    {
        imageSize.width = imageSize.height;
    }
    else
    {
        imageSize.height = imageSize.width;
    }
    
    CGFloat borderWidth = borderColor == nil ? 0 : 2.0f*imageSize.width/48.0f;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize.width + 2*borderWidth, imageSize.height + 2*borderWidth), NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(context)
    {
        [[UIColor clearColor] set];
        CGContextFillRect(context, CGRectMake(0, 0, imageSize.width + 2*borderWidth, imageSize.height + 2*borderWidth));
        
        CGPoint center = CGPointMake((imageSize.width + 2*borderWidth)/2, (imageSize.height + 2*borderWidth)/2);
        
        CGFloat radius = imageSize.width > imageSize.height ? imageSize.height/2 : imageSize.width/2;
        
        if (borderColor != nil)
        {
            CGContextSaveGState(context);
            
            CGFloat outerRadius = radius + borderWidth;
            
            CGContextSetLineWidth(context, borderWidth);
            [borderColor set];
            
            CGContextAddArc(context, center.x, center.y, radius, 0, 2*M_PI, 1);
            CGContextAddArc(context, center.x, center.y, outerRadius, 0, 2*M_PI, 1);
            CGContextClosePath(context);
            
            CGContextEOClip(context);
            
            CGContextFillRect(context, CGRectMake(0, 0, imageSize.width + 2*borderWidth, imageSize.height + 2*borderWidth));
            
            CGContextRestoreGState(context);
        }
        
        CGContextSaveGState(context);
        
        CGContextAddArc(context, center.x, center.y, radius, 0, 2*M_PI, 1);
        CGContextClip(context);
        
        CGRect rectForImage = CGRectMake((imageSize.width - image.size.width)/2 + borderWidth, (imageSize.height - image.size.height)/2 + borderWidth, imageSize.width, imageSize.height);
        [image drawInRect:rectForImage];
        
        CGContextRestoreGState(context);
        
        retImage = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    
    UIGraphicsEndImageContext();
    
    return retImage;
}




+(BOOL)isDisplayNameValid:(NSString*)aName
{
    NSRange atRange = [aName rangeOfString:[NSString stringWithFormat:@"@%@",QIKACHAT_DOMAIN_NAME]];
    if( !aName || atRange.location != NSNotFound )
        return NO;
    else
        return YES;
}

+(NSString*)displayName:(NSString*)aJID
{
    NSRange atRange = [aJID rangeOfString:@"@"];
    if (atRange.location != NSNotFound)
    {
        return [aJID substringToIndex:atRange.location];
    }
    return aJID;
}

+(NSString*)bareJID:(NSString*)aNumber
{
    NSRange atRange = [aNumber rangeOfString:@"@"];
    if (atRange.location == NSNotFound)
    {
        return [NSString stringWithFormat:@"%@@%@", aNumber, QIKACHAT_DOMAIN_NAME ];
    }
    return aNumber;
}


+(NSString*)bareXabberJID:(NSString*)aNumber
{
    NSRange atRange = [aNumber rangeOfString:@"@"];
    if (atRange.location == NSNotFound)
    {
        return [NSString stringWithFormat:@"%@", aNumber];
    }
    return aNumber;
}


+(NSDateFormatter*) dateFormatorInstance
{
    static NSDateFormatter *globaldateFormatter = nil;
    
    @synchronized(globaldateFormatter)
    {
        if(globaldateFormatter == nil)
        {
            globaldateFormatter = [[NSDateFormatter alloc] init];
        }
        return globaldateFormatter;
    }
}
/**
 *
 */
+(NSString *) dateToString:(NSDate *) date withFormat:(NSString *) format
{
    NSString *result = nil;
    
    if(date && format && [format length] > 0)
    {
        NSDateFormatter* formator = [Utility dateFormatorInstance];
        if( formator )
        {
            [formator setDateFormat:format];
            result = [formator stringFromDate:date];
        }
    }
    if( ![result length] )
        return @"";
    
    return result;
}

/**
 *
 */
+(NSDate *) stringToDate:(NSString *) stamp withFormat:(NSString *) format
{
    NSDate * result = nil;
    if(stamp && [stamp length] > 0 && format && [format length] > 0 )
    {
        NSDateFormatter* formator = [Utility dateFormatorInstance];
        if( formator )
        {
            [formator setDateFormat:format];
            NSError *error = nil;
            [formator getObjectValue:&result forString:stamp range:nil error:&error];
        }
    }
    return result;
}

+(NSString *) timeToShortStringForDisplay:(NSDate *) date
{
    NSString *result = nil;
    if(date)
    {
        result = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle: NSDateFormatterShortStyle];
    }
    if( ![result length] )
        return @"";
    
    return result;
}

+ (NSString *) contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (NSString*) getTimestampForDate:(NSDate*)date{
    
    if( !date )
        return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    
    NSString* timestamp;
    int timeIntervalInHours = (int)[[NSDate date] timeIntervalSinceDate:date] /3600;
    
    if(timeIntervalInHours < 24){//less than 1 day
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Today at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 48){//less than 2 days
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Yesterday at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 168){//less than  a week
        
        [dateFormatter setDateFormat:@"h:mm a, dd/MM/yyyy"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }else{//older than a week
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }
    return timestamp;
}

+ (NSString*) getTimestampForChat:(NSDate*)date{
    
    if( !date )
        return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    
    NSString* timestamp;
    int timeIntervalInHours = (int)[[NSDate date] timeIntervalSinceDate:date] /3600;
    
    if(timeIntervalInHours < 24){//less than 1 day
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 48){//less than 2 days
        
        timestamp = [NSString stringWithFormat:@"Yesterday"];
    }else{
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }
    return timestamp;
}


+ (id) createDataWithMessage:(Message *)message {
    
    NSBubbleData *sayBubble =nil;
    
    if( !message )
        return sayBubble;
    
    NSBubbleType type = BubbleTypeSomeoneElse;
    if( message.isOutGoing )
        type = BubbleTypeMine;
    
    if( message.messageType == TEXT_TYPE_MESSAGE ){
        sayBubble = [NSBubbleData dataWithText:message.body date:message.date type:type];
    }
    else if( message.fileData && message.messageType == IMAGE_TYPE_MESSAGE )
    {
        if (message.fileData != nil) {
            UIImage *img = [UIImage imageWithData:message.fileData];
            sayBubble = [NSBubbleData dataWithImage:img date:message.date type:type];
        }
    }
    else if( message.messageType == AUDIO_TYPE_MESSAGE )
    {
        UIImage* image = [UIImage imageNamed:@"micro.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, 100,100);
        sayBubble = [NSBubbleData dataWithImage:image date:message.date type:type];
    }
    else if (message.messageType == LOCATION_TYPE_MESSAGE)
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:message.date type:type];
    }
    else
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:message.date type:type];
    }
    
    return sayBubble;
}



@end
