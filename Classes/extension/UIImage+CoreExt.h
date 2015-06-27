//
//  UIImage+CoreExt.h
//  RAMC
//
//  Created by Randolph Lee on 6/10/14.
//  Copyright (c) 2014 shoto. All rights reserved.
//
#import "QikAChat-Prefix.pch"

@interface UIImage (CoreExt)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)clearImage;
- (UIImage *)decodedImage;

@end
