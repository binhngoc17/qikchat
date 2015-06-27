//
//  Utility.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 27/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "Utility.h"

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

@end
