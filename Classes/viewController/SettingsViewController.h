//
//  SettingsViewController.h
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController 
{
  UITextField *jidField;
  UITextField *passwordField;
}

@property (nonatomic,strong) IBOutlet UITextField *jidField;
@property (nonatomic,strong) IBOutlet UITextField *passwordField;

- (IBAction)done:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
