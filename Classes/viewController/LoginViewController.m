//
//  LoginViewController.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "LoginViewController.h"
#import "QikAChat-Prefix.pch"
#import "Strings.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#define  kXLabelTopMargin    10.0f
#define  kXLabelFieldHight   40.0f
#define KEY_BOARD_ADJUSTMENT    50
#define KEY_BOARD_ADJUSTMENT_SPEED 0.25


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dQikAColor];
    
    _controllView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _controllView.backgroundColor = dClearColor;
    [self.view addSubview:_controllView];
    
    int scrnwidth = [UIScreen mainScreen].bounds.size.width;
    int scrnheight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect fieldframe = CGRectMake((scrnwidth-260)/2,
                                   scrnheight/2 + 2*kXLabelFieldHight, 260, kXLabelFieldHight);
    
    UIButton* signButton = [[UIButton alloc] initWithFrame:fieldframe];
    [signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [signButton setTitle:[NSLocalizedString(btnLogin, nil) capitalizedString] forState:UIControlStateNormal];
    [signButton addTarget:self action:@selector(signingAction:) forControlEvents:UIControlEventTouchUpInside];
    [signButton setBackgroundColor:[UIColor lightGrayColor]];
    signButton.layer.cornerRadius = 6.0f;
    [_controllView addSubview:signButton];
    
    fieldframe.origin.y = fieldframe.origin.y -kXLabelFieldHight-kXLabelTopMargin;
    
    _passwordTextField = [[UITextField alloc] initWithFrame:fieldframe];
    _passwordTextField.placeholder = NSLocalizedString(lblYourPassworld, nil);
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.contentMode = UIViewContentModeScaleAspectFit;
    _passwordTextField.textAlignment = NSTextAlignmentCenter;
    _passwordTextField.delegate = self;
    _passwordTextField.layer.cornerRadius = 6.0f;
    _passwordTextField.backgroundColor = [UIColor whiteColor];
    [_controllView addSubview: _passwordTextField];
    
    fieldframe.origin.y = fieldframe.origin.y -kXLabelFieldHight-kXLabelTopMargin;
    
    _usernameTextField = [[UITextField alloc] initWithFrame:fieldframe];
    _usernameTextField.placeholder = NSLocalizedString(lblYourUserId, nil);
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _usernameTextField.contentMode = UIViewContentModeScaleAspectFit;
    _usernameTextField.textAlignment = NSTextAlignmentCenter;
    _usernameTextField.delegate = self;
    _usernameTextField.layer.cornerRadius = 6.0f;
    _usernameTextField.backgroundColor = [UIColor whiteColor];
    [_controllView addSubview: _usernameTextField];
    
    
    fieldframe.origin.y = fieldframe.origin.y -kXLabelFieldHight-kXLabelTopMargin;
    
    _displayNameField = [[UITextField alloc] initWithFrame:fieldframe];
    _displayNameField.placeholder = NSLocalizedString(lblYourDisplayName, nil);
    _displayNameField.returnKeyType = UIReturnKeyNext;
    _displayNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _displayNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _displayNameField.contentMode = UIViewContentModeScaleAspectFit;
    _displayNameField.textAlignment = NSTextAlignmentCenter;
    _displayNameField.delegate = self;
    _displayNameField.layer.cornerRadius = 6.0f;
    _displayNameField.backgroundColor = [UIColor whiteColor];
    [_controllView addSubview: _displayNameField];
    
    fieldframe.origin.y = fieldframe.origin.y -4*kXLabelFieldHight-kXLabelTopMargin*2;
    fieldframe.size.height =  fieldframe.size.height*4;
    
    _termsofUse = [[UILabel alloc] initWithFrame:fieldframe];
    _termsofUse.contentMode = UIViewContentModeRedraw;
    _termsofUse.textAlignment = NSTextAlignmentCenter;
    _termsofUse.layer.cornerRadius = 6.0f;
    _termsofUse.lineBreakMode = NSLineBreakByWordWrapping;
    _termsofUse.numberOfLines = 5;
    _termsofUse.backgroundColor = [UIColor clearColor];
    [_termsofUse setText:NSLocalizedString(lblTermsofUseText, nil)];
    [_termsofUse setFont:fontThinOfSize(14)];
    [self.view addSubview: _termsofUse];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    _displayNameField.text =@"";
    _usernameTextField.text = @"";
    _passwordTextField.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticated:) name:USER_AUTHENTICATED_NOTIFICATION object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_AUTHENTICATED_NOTIFICATION object:nil];
}

-(void) signingAction:(id) sender
{
    [_controllView endEditing:YES];// this will do the trick
    [self handleKeyboardHide];
    _keyBoardIsVisible = NO;

    if( ![_usernameTextField.text length] || ![_passwordTextField.text length]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error"
                                                        message:@"You must enter user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if( !_spiner )
        _spiner = [[UIActivitySpiner alloc] initWithFrame:CGRectMake((self.view.frame.size.width-50)/2, 60 , 50, 50)];
    else
        [_spiner removeFromSuperview];
    
    [[ProfileDataManager sharedInstance] setDisplayName:_displayNameField.text];
    [[ProfileDataManager sharedInstance] setXabberID:_usernameTextField.text];
    [[ProfileDataManager sharedInstance] setPassword:_passwordTextField.text];
    [xmppInstance connect];
    
    [_controllView addSubview:_spiner];
    [_spiner createAndShowSpinner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) userAuthenticated:(NSNotification*) aNotification{
    NSObject *obj = [aNotification object];
    
    [_spiner hideAndStopSpinner];
    _spiner = nil;
    
    if( obj != nil ){
        [[ProfileDataManager sharedInstance] setPassword:@""];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error!"
                                                        message:@"Some thing went wrong, please try again!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }else
    {
        [[ProfileDataManager sharedInstance] setHasCreatedAccount:YES];
        [self dismissViewControllerAnimated:YES completion:NULL];
        [[UIController getUIController] showMainScreen];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_controllView endEditing:YES];// this will do the trick
    [self handleKeyboardHide];
    _keyBoardIsVisible = NO;
}

#pragma mark <UITextFieldDelegate> Methods
-(void) handleKeyboardVisible:(BOOL)animated
{
    if (!animated)
    {
        if (_keyBoardIsVisible)
            return;
        
        _keyBoardIsVisible = TRUE;
        
        CGRect frame=_controllView.frame;
        frame.origin.y -= KEY_BOARD_ADJUSTMENT;
        _controllView.frame=frame;
    }
    else
    {
        [self handleKeyboardVisible];
    }
}

-(void) handleKeyboardVisible
{
    if( _spiner ){
        [xmppInstance disconnect];
        [_spiner hideAndStopSpinner];
        _spiner = nil;
    }

    if (_keyBoardIsVisible)
        return;
    
    _keyBoardIsVisible = TRUE;
    
    CGRect frame=_controllView.frame;
    frame.origin.y -= KEY_BOARD_ADJUSTMENT;
    
    [UIView animateWithDuration:KEY_BOARD_ADJUSTMENT_SPEED animations:^{
        
        _controllView.frame=frame;
        
    }];
    
}

-(void) handleKeyboardHide
{
    if (!_keyBoardIsVisible)
        return;
    
    _keyBoardIsVisible = FALSE;
    
    CGRect frame=_controllView.frame;
    frame.origin.y += KEY_BOARD_ADJUSTMENT;
    
    
    [UIView animateWithDuration:KEY_BOARD_ADJUSTMENT_SPEED animations:^{
        
        _controllView.frame=frame;
        
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self handleKeyboardVisible];
    _keyBoardIsVisible = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( _displayNameField == textField )
    {
        if( textField.text.length )
            [_usernameTextField becomeFirstResponder];
    }
    else if( _usernameTextField == textField )
    {
        if( textField.text.length )
            [_passwordTextField becomeFirstResponder];
    }
    else if( _passwordTextField == textField )
    {
        if( textField.text.length ){
            [self signingAction:self];
        }
        [textField resignFirstResponder];
        [self handleKeyboardHide];
        _keyBoardIsVisible = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
