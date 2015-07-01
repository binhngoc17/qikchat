//
//  UIActivitySpiner.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "UIActivitySpiner.h"

@implementation UIActivitySpiner

#define kSpinnerInset   5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

-(UIColor*) getFontColor
{
    NSInteger yiq = ((1 * 299) + (1 * 587) + (1 * 114)) / 1000;
    return (yiq >= 128)? [UIColor blackColor] : [UIColor whiteColor];
}

-(void) createAndShowSpinner
{
    CGRect frame=  self.frame;
    if (_spinner == nil)
    {
        UIColor *suggestedColor = [self getFontColor];
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        if (CGColorEqualToColor(suggestedColor.CGColor, [UIColor blackColor].CGColor))
        {
            CGFloat width = frame.size.width + 4*kSpinnerInset;
            CGFloat height = frame.size.height + 4*kSpinnerInset;
            CGRect spinnerBackgroundFrame = CGRectMake(frame.origin.x,
                                                       frame.origin.y,
                                                       width,
                                                       height);
            
            _spinnerBackground = [[UIView alloc] initWithFrame:spinnerBackgroundFrame];
            _spinnerBackground.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            _spinnerBackground.layer.cornerRadius = spinnerBackgroundFrame.size.height/2;
            
            [self addSubview:_spinnerBackground];
            
            _spinner.frame = CGRectInset(_spinnerBackground.bounds, 2*kSpinnerInset, 2*kSpinnerInset);
            
        }
        else
        {
            float xPos = (frame.size.width - _spinner.bounds.size.width) / 2;
            float yPos = frame.origin.y+kSpinnerInset;
            
            _spinner.frame = CGRectMake(xPos, yPos, _spinner.bounds.size.width, _spinner.bounds.size.height);
            
            [self addSubview:_spinner];
        }
    
        [_spinner startAnimating];
    }
}

-(void) hideAndStopSpinner
{
    if( _spinner ){
        [_spinner removeFromSuperview];
        _spinner = nil;
    }
    
    if( _spinnerBackground ){
        [_spinnerBackground removeFromSuperview];
        _spinnerBackground = nil;
    }
}

@end
