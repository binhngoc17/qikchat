//
//  ChatViewController.m
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 02/07/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import "ChatViewController.h"
#import "QikAChat-Prefix.pch"
#import "Chat.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"


@interface ChatViewController ()
{
    UIBubbleTableView *bubbleTable;
    UIView *textInputView;
    UITextField *textField;
    UIButton* sendButton;
    UIImage* defaultAvatar;
}
@property(nonatomic, strong) Chat* currentChat;
@end
 
@implementation ChatViewController

+(ChatViewController*) sharedViewWitChat:(Chat*) achat{
    
    if( achat == nil )
        return nil;
    
    static ChatViewController *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[ChatViewController alloc] init];
        }
        [sharedSingleton setupChat:achat];
        return sharedSingleton;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:dClearColor];
    [self initTableView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    
    [self initTitleSegement];
    [self.view endEditing:YES];
    
    self.currentChat.chatDelegate  = self;
    [self.currentChat setActive:YES];
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (defaultAvatar.png)
    
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [bubbleTable reloadData];
    [self scrollToBottom:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self.currentChat setActive:NO];
    self.currentChat.chatDelegate  = nil;
    
    [[self navigationController] setNavigationBarHidden:false animated:YES];
    [appInstance setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [super viewWillDisappear:animated];
}

- (void) initTableView {
    bubbleTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.delegate = self;
    
    UITapGestureRecognizer *tapGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [bubbleTable addGestureRecognizer:tapGesture];
    
    [self.view addSubview:bubbleTable];
    [bubbleTable setBackgroundColor:dClearColor];
    
    textInputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    [self.view addSubview:textInputView];
    [textInputView setBackgroundColor:dQikAColor];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-60, 40)];
    [textInputView addSubview:textField];
    [textField setBackgroundColor:[UIColor whiteColor]];
    textField.layer.cornerRadius = 10.0f;
    textField.layer.borderColor = dBorderColor.CGColor;
    textField.layer.borderWidth = 2.0f;
    textField.delegate = self;
    
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60+10, 5, 45, 40)];
    [textInputView addSubview:sendButton];
    [sendButton setBackgroundColor:[UIColor clearColor]];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupChat:(Chat*) newChat
{
    if( self.currentChat != newChat ){
       [self.currentChat setActive:FALSE];
        self.currentChat = newChat;
        [self.currentChat loadMessagesFromDB];
    }
}

-(UIImage*) defaultAvatarImage{
    if( defaultAvatar )
        return defaultAvatar;
    
   defaultAvatar = [UIImage imageNamed:@"defaultAvatar.png"];
    return defaultAvatar;
}

- (void) initTitleSegement {
   
    self.navigationItem.hidesBackButton = YES;
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 45)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
    [titleView addSubview:backButton];
    

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 2, self.view.frame.size.width-100, 40)];
    titleLabel.text = [self.currentChat getDisplayName];
    
    [titleView addSubview:titleLabel];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-55, 0, 40, 40)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"navmenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:menuButton];
    
    self.navigationItem.titleView = titleView;
    
}

-(void) backAction:(id) sender{
    [self.currentChat setActive:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) menuAction:(id) sender{
   
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported"
                                                        message:@"Selected feature is not implemenetd!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) scrollToBottom:(BOOL) animated{
    [bubbleTable scrollBubbleViewToBottomAnimated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [[self.currentChat allUiMessageArray] count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [[self.currentChat allUiMessageArray] objectAtIndex:row];
}


#pragma mark - Keyboard events
-(void) asychScrollTable{
    [self scrollToBottom:NO];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
        
        [self performSelectorOnMainThread:@selector(asychScrollTable) withObject:nil waitUntilDone:NO];

    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
        
        [self performSelectorOnMainThread:@selector(asychScrollTable) withObject:nil waitUntilDone:NO];

    }];
}

#pragma mark - Actions

- (void)sendPressed:(id)sender
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSString *msg = textField.text;
    if([[msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [textField resignFirstResponder];
        return;
    }
    
    Message *message = [Message messageWithText:msg withJid:self.currentChat.chatJid];
    message.messageType = TEXT_TYPE_MESSAGE;
    
    [self.currentChat sendChatMessage:message];
    textField.text = @"";
    
    [self aSynchReloadTableData];
}

#pragma mark - UITextFieldDelegate implementation

- (void)textFieldDidBeginEditing:(UITextField *)atextField{
    bubbleTable.typingBubble = NSBubbleTypingTypeMe;
}
- (void)textFieldDidEndEditing:(UITextField *)atextField{
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)atextField{
   
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    if( [atextField.text length] )
        [self sendPressed:nil];
    
    return YES;
}

-(void) handleAllMessageLoaded:(NSObject*) aObject{
    [self performSelectorOnMainThread:@selector(aSynchReloadTableData) withObject:nil waitUntilDone:NO];
}

-(void) handleMessageListChange:(NSString*) aBareJid {
    [self performSelectorOnMainThread:@selector(aSynchReloadTableData) withObject:nil waitUntilDone:NO];
}

-(void) handleChatStateChange:(OTRChatState)aState{
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [self scrollToBottom:YES];
}

-(void) aSynchReloadTableData{
    [bubbleTable reloadData];
    [self scrollToBottom:YES];
}

#pragma keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

-(void)didTapOnTableView:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

@end
