//
//  SettingsViewController.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileDataManager.h"
#import "Literals.h"

@implementation SettingsViewController

@synthesize jidField;
@synthesize passwordField;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Init/dealloc methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib {
  self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
   jidField.text = [[ProfileDataManager sharedInstance] getXabberID:nil];
   passwordField.text = [[ProfileDataManager sharedInstance] getPassword:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)done:(id)sender
{
    if( ![jidField.text length] || ![passwordField.text length]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"You must enter user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
  }
  [[ProfileDataManager sharedInstance] setXabberID:jidField.text];
  [[ProfileDataManager sharedInstance] setPassword:passwordField.text];

  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)hideKeyboard:(id)sender {
  [sender resignFirstResponder];
  [self done:sender];
}


@end
