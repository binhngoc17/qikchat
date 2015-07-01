//
//  LoginViewController.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 30/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIActivitySpiner.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    UITextField *_displayNameField;
    UITextField *_usernameTextField;
    UITextField *_passwordTextField;
    
    BOOL _keyBoardIsVisible;
    UIView* _controllView;
    UIActivitySpiner* _spiner;
}
@end
