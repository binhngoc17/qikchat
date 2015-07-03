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
    NSMutableArray *bubbleData;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = NO;
    [self initTableView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    
    [[self navigationController] setNavigationBarHidden:self.navigationBarHidden animated:YES];
    [appInstance setStatusBarHidden:self.navigationBarHidden withAnimation:UIStatusBarAnimationNone];
  
    [self initTitleSegement];
 
    [self.currentChat setActive:YES];
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = NO;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    if( self.isReloadTabble )
        [bubbleTable reloadData];
    else
        [bubbleTable reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.currentChat setActive:NO];
    [[self navigationController] setNavigationBarHidden:false animated:YES];
    [appInstance setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [super viewWillDisappear:animated];
}

- (void) initTableView {
    bubbleTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.delegate = self;
    
    [self.view addSubview:bubbleTable];
    [bubbleTable setBackgroundColor:[UIColor whiteColor]];
    
    textInputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    [self.view addSubview:textInputView];
    [textInputView setBackgroundColor:tableColor];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-60, 40)];
    [textInputView addSubview:textField];
    [textField setBackgroundColor:[UIColor whiteColor]];
    textField.layer.cornerRadius = 10.0f;
    textField.layer.borderColor = headerColor.CGColor;
    textField.layer.borderWidth = 2.0f;
    
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60+10, 5, 45, 40)];
    [textInputView addSubview:sendButton];
    [sendButton setBackgroundColor:[UIColor clearColor]];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    bubbleData = [[NSMutableArray alloc] init];
    bubbleTable.bubbleDataSource = self;
    
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
        self.isReloadTabble = YES;
    }
    else
        self.isReloadTabble = NO;
}

- (void) initTitleSegement {
    
    UIView *segmentedView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.frame.size.width, 60}];
    
    UIImageView* avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
    [avatarView setBackgroundColor:[UIColor clearColor]];
    avatarView.image = [Utility roundImageWithImage:[UIImage imageNamed:@"defaultAvatar.png"] borderColor:[UIColor blackColor]];
    avatarView.layer.cornerRadius = 3.0f;
    avatarView.clipsToBounds = YES;
    [segmentedView addSubview:avatarView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50+10, 15, self.view.frame.size.width-85, 44)];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString* displayName = [self.currentChat getDisplayName];
    if ([displayName length])
    {
        titleLabel.text = displayName;
    }
    else
    {
        titleLabel.text = [self.currentChat chatJid];
    }
    
    [titleLabel sizeToFit];
    
    [segmentedView addSubview:titleLabel];
    
    UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 10, 35, 35)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"navmenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [segmentedView addSubview:menuButton];
    
    self.navigationItem.titleView = segmentedView;
    
}

-(void) menuAction:(id) sender{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(NSBubbleData*) addSentMessage:(Message*) message scroll:(BOOL) aScroll
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble =nil;
    if( message.messageType == TEXT_TYPE_MESSAGE ){
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeMine];
    }
    else if( message.fileData && message.messageType == IMAGE_TYPE_MESSAGE )
    {
        if (message.fileData != nil) {
            UIImage *img = [UIImage imageWithData:message.fileData];
            sayBubble = [NSBubbleData dataWithImage:img date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeMine];
        } else {
            //sayBubble = [NSBubbleData dataWithImage:img date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
        }
    }
    else if( message.messageType == AUDIO_TYPE_MESSAGE )
    {
        UIImage* image = [UIImage imageNamed:@"micro.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, 100,100);
        sayBubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeMine];
    }
    else if (message.messageType == LOCATION_TYPE_MESSAGE)
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeMine];
    }
    else
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeMine];
  }
    
   //[sayBubble setExtObject:message];
   //sayBubble.status = message.messageStatus;
    
    ProfileDataManager *myAccount = [ProfileDataManager sharedInstance];
    UIImage* avatarImage =  myAccount.myAvatar;
    sayBubble.avatar = avatarImage;
    
    [bubbleData addObject:sayBubble];
    
    if( aScroll ){
        [bubbleTable reloadData];
        //[bubbleTable insertbubbleAtEnd:sayBubble];
        [self scrollToBottom];
    }
    
    return sayBubble;
}

-(void) scrollToBottom{
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[bubbleData count]-1 inSection:0];
    [bubbleTable scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

-(NSBubbleData*) addRecievedMessage:(Message*) message scroll:(BOOL) aScroll
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble =nil;
    if( message.messageType == TEXT_TYPE_MESSAGE ){
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    }
    else if( message.fileData && message.messageType == IMAGE_TYPE_MESSAGE )
    {
        if (message.fileData != nil) {
            UIImage *img = [UIImage imageWithData:message.fileData];
            sayBubble = [NSBubbleData dataWithImage:img date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
        } else {
            //sayBubble = [NSBubbleData dataWithImage:img date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
        }
    }
    else if( message.messageType == AUDIO_TYPE_MESSAGE )
    {
        UIImage* image = [UIImage imageNamed:@"micro.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, 100,100);
        sayBubble = [NSBubbleData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
    }
    else if (message.messageType == LOCATION_TYPE_MESSAGE)
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    }
    else
    {
        sayBubble = [NSBubbleData dataWithText:message.body date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    }
    
    //  [sayBubble setExtObject:message];
    // sayBubble.status = message.messageStatus;
    
    /* Buddy *myAccount = [[[XmppController sharedSingleton] rosterController] getRegisteredUserBuddy];
     UIImage* avatarImage =  myAccount.avatarImage;
     
     if( avatarImage == nil )
     {
     NSString *imgName = [[ThemeManager sharedManger] getImageNameForKey:DEFAULT_USER_IMAGE];
     avatarImage = [UIImage imageNamed:imgName];
     }
     sayBubble.avatar = avatarImage;
     */
    
    [bubbleData addObject:sayBubble];
    
    if( aScroll ){
        [bubbleTable reloadData];
        //[bubbleTable insertbubbleAtEnd:sayBubble];
        [self scrollToBottom];
    }
    
    return sayBubble;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

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
    [self addSentMessage:message scroll:YES];
    textField.text = @"";
}

@end
