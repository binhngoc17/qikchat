//
//  UIActivitySpiner.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivitySpiner : UIView
{
UIActivityIndicatorView *_spinner;
UIView *_spinnerBackground;
}
- (id)initWithFrame:(CGRect)frame;
-(void) createAndShowSpinner;
-(void) hideAndStopSpinner;
@end
