//
//  UIMessageBarView.m
//  QikAChat
//
//  Created by Ram Chauhan on 27/06/2015.
//  Copyright (c) 2015 RAMC. All rights reserved.
//


#import "UIMessageBarManager.h"

// Quartz
#import <QuartzCore/QuartzCore.h>

// Numerics (TWMessageBarStyleSheet)
CGFloat const kTWMessageBarStyleSheetMessageBarAlpha = 0.96f;

// Numerics (TWMessageView)
CGFloat const kTWMessageViewBarPadding = 10.0f;
CGFloat const kTWMessageViewIconSize = 36.0f;
CGFloat const kTWMessageViewTextOffset = 2.0f;
NSUInteger const kTWMessageViewiOS7Identifier = 7;

// Numerics (TWMessageBarManager)
CGFloat const kTWMessageBarManagerDisplayDelay = 3.0f;
CGFloat const kTWMessageBarManagerDismissAnimationDuration = 0.25f;
CGFloat const kTWMessageBarManagerPanVelocity = 0.2f;
CGFloat const kTWMessageBarManagerPanAnimationDuration = 0.0002f;

// Strings (TWMessageBarStyleSheet)
NSString * const kTWMessageBarStyleSheetImageIconError = @"icon-error.png";
NSString * const kTWMessageBarStyleSheetImageIconSuccess = @"icon-success.png";
NSString * const kTWMessageBarStyleSheetImageIconInfo = @"icon-info.png";

// Fonts (TWMessageView)
static UIFont *kTWMessageViewTitleFont = nil;
static UIFont *kTWMessageViewDescriptionFont = nil;

// Colors (TWMessageView)
static UIColor *kTWMessageViewTitleColor = nil;
static UIColor *kTWMessageViewDescriptionColor = nil;

// Colors (TWDefaultMessageBarStyleSheet)
static UIColor *kTWDefaultMessageBarStyleSheetErrorBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetSuccessBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetInfoBackgroundColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetErrorStrokeColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetSuccessStrokeColor = nil;
static UIColor *kTWDefaultMessageBarStyleSheetInfoStrokeColor = nil;

@protocol UIMessageViewDelegate;

@interface UIMessageView : UIView

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *descriptionString;

@property (nonatomic, assign) UIMessageBarMessageType messageType;

@property (nonatomic, assign) BOOL hasCallback;
@property (nonatomic, strong) NSArray *callbacks;

@property (nonatomic, assign, getter = isHit) BOOL hit;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, weak) id <UIMessageViewDelegate> delegate;

// Initializers
- (id)initWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type;

// Getters
- (CGFloat)height;
- (CGFloat)width;
- (CGFloat)statusBarOffset;
- (CGFloat)availableWidth;
- (CGSize)titleSize;
- (CGSize)descriptionSize;
- (CGRect)statusBarFrame;
- (UIFont *)titleFont;
- (UIFont *)descriptionFont;
- (UIColor *)titleColor;
- (UIColor *)descriptionColor;

// Helpers
- (CGRect)orientFrame:(CGRect)frame;

// Notifications
- (void)didChangeDeviceOrientation:(NSNotification *)notification;

@end

@protocol UIMessageViewDelegate <NSObject>

- (NSObject<UIMessageBarStyleSheet> *)styleSheetForMessageView:(UIMessageView *)messageView;

@end

@interface UIDefaultMessageBarStyleSheet : NSObject <UIMessageBarStyleSheet>

+ (UIDefaultMessageBarStyleSheet *)styleSheet;

@end

@interface UIMessageWindow : UIWindow

@end

@interface UIMessageBarViewController : UIViewController

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;

@end

@interface UIMessageBarManager () <UIMessageViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageBarQueue;
@property (nonatomic, assign, getter = isMessageVisible) BOOL messageVisible;
@property (nonatomic, strong) UIMessageWindow *messageWindow;
@property (nonatomic, readwrite) NSArray *accessibleElements; // accessibility

// Static
+ (CGFloat)durationForMessageType:(UIMessageBarMessageType)messageType;

// Helpers
- (void)showNextMessage;
- (void)generateAccessibleElementWithTitle:(NSString *)title description:(NSString *)description;

// Gestures
- (void)itemSelected:(UITapGestureRecognizer *)recognizer;

// Getters
- (UIView *)messageWindowView;
- (UIMessageBarViewController *)messageBarViewController;

// Master presetation
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration statusBarHidden:(BOOL)statusBarHidden statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback;

@end

@implementation UIMessageBarManager

#pragma mark - Singleton

+ (UIMessageBarManager *)sharedInstance
{
    static dispatch_once_t pred;
    static UIMessageBarManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
	return instance;
}

#pragma mark - Static

+ (CGFloat)defaultDuration
{
    return kTWMessageBarManagerDisplayDelay;
}

+ (CGFloat)durationForMessageType:(UIMessageBarMessageType)messageType
{
    return kTWMessageBarManagerDisplayDelay;
}

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _messageBarQueue = [[NSMutableArray alloc] init];
        _messageVisible = NO;
        _styleSheet = [UIDefaultMessageBarStyleSheet styleSheet];
    }
    return self;
}

#pragma mark - Public

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type
{
    [self showMessageWithTitle:title description:description type:type duration:[UIMessageBarManager durationForMessageType:type] callback:nil];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:[UIMessageBarManager durationForMessageType:type] callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration
{
    [self showMessageWithTitle:title description:description type:type duration:duration callback:nil];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:duration statusBarStyle:UIStatusBarStyleDefault callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:kTWMessageBarManagerDisplayDelay statusBarStyle:statusBarStyle callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:duration statusBarHidden:NO statusBarStyle:statusBarStyle callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type statusBarHidden:(BOOL)statusBarHidden callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:[UIMessageBarManager durationForMessageType:type] statusBarHidden:statusBarHidden statusBarStyle:UIStatusBarStyleDefault callback:callback];
}

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration statusBarHidden:(BOOL)statusBarHidden callback:(void (^)())callback
{
    [self showMessageWithTitle:title description:description type:type duration:duration statusBarHidden:statusBarHidden statusBarStyle:UIStatusBarStyleDefault callback:callback];
}

#pragma mark - Master Presentation

- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type duration:(CGFloat)duration statusBarHidden:(BOOL)statusBarHidden statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback
{
    UIMessageView *messageView = [[UIMessageView alloc] initWithTitle:title description:description type:type];
    messageView.delegate = self;
    
    messageView.callbacks = callback ? [NSArray arrayWithObject:callback] : [NSArray array];
    messageView.hasCallback = callback ? YES : NO;
    
    messageView.duration = duration;
    messageView.hidden = YES;
    
    messageView.statusBarStyle = statusBarStyle;
    messageView.statusBarHidden = statusBarHidden;
    
    [[self messageWindowView] addSubview:messageView];
    [[self messageWindowView] bringSubviewToFront:messageView];
    
    [self.messageBarQueue addObject:messageView];
    
    if (!self.messageVisible)
    {
        [self showNextMessage];
    }
}

- (void)hideAllAnimated:(BOOL)animated
{
    for (UIView *subview in [[self messageWindowView] subviews])
    {
        if ([subview isKindOfClass:[UIMessageView class]])
        {
            UIMessageView *currentMessageView = (UIMessageView *)subview;
            if (animated)
            {
                [UIView animateWithDuration:kTWMessageBarManagerDismissAnimationDuration animations:^{
                    currentMessageView.frame = CGRectMake(currentMessageView.frame.origin.x, -currentMessageView.frame.size.height, currentMessageView.frame.size.width, currentMessageView.frame.size.height);
                } completion:^(BOOL finished) {
                    [currentMessageView removeFromSuperview];
                }];
            }
            else
            {
                [currentMessageView removeFromSuperview];
            }
        }
    }
    
    self.messageVisible = NO;
    [self.messageBarQueue removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)hideAll
{
    [self hideAllAnimated:NO];
}

#pragma mark - Helpers

- (void)showNextMessage
{
    if ([self.messageBarQueue count] > 0)
    {
        self.messageVisible = YES;
        
        UIMessageView *messageView = [self.messageBarQueue objectAtIndex:0];
        [self messageBarViewController].statusBarHidden = messageView.statusBarHidden; // important to do this prior to hiding
        messageView.frame = CGRectMake(0, -[messageView height], [messageView width], [messageView height]);
        messageView.hidden = NO;
        [messageView setNeedsDisplay];
        
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemSelected:)];
        [messageView addGestureRecognizer:gest];
        
        if (messageView)
        {
            [self.messageBarQueue removeObject:messageView];
            
            [self messageBarViewController].statusBarStyle = messageView.statusBarStyle;

            [UIView animateWithDuration:kTWMessageBarManagerDismissAnimationDuration animations:^{
                [messageView setFrame:CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y + [messageView height], [messageView width], [messageView height])]; // slide down
            }];
            [self performSelector:@selector(itemSelected:) withObject:messageView afterDelay:messageView.duration];
            
            [self generateAccessibleElementWithTitle:messageView.titleString description:messageView.descriptionString];
        }
    }
}

- (void)generateAccessibleElementWithTitle:(NSString *)title description:(NSString *)description
{
    UIAccessibilityElement *textElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    textElement.accessibilityLabel = [NSString stringWithFormat:@"%@\n%@", title, description];
    textElement.accessibilityTraits = UIAccessibilityTraitStaticText;
    self.accessibleElements = @[textElement];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self); // notify the accessibility framework to read the message
}

#pragma mark - Gestures

- (void)itemSelected:(id)sender
{
    UIMessageView *messageView = nil;
    BOOL itemHit = NO;
    if ([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        messageView = (UIMessageView *)((UIGestureRecognizer *)sender).view;
        itemHit = YES;
    }
    else if ([sender isKindOfClass:[UIMessageView class]])
    {
        messageView = (UIMessageView *)sender;
    }
    
    if (messageView && ![messageView isHit])
    {
        messageView.hit = YES;
        
        [UIView animateWithDuration:kTWMessageBarManagerDismissAnimationDuration animations:^{
            [messageView setFrame:CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y - [messageView height], [messageView width], [messageView height])]; // slide back up
        } completion:^(BOOL finished) {
            self.messageVisible = NO;
            [messageView removeFromSuperview];
            
            if (itemHit)
            {
                if ([messageView.callbacks count] > 0)
                {
                    id obj = [messageView.callbacks objectAtIndex:0];
                    if (![obj isEqual:[NSNull null]])
                    {
                        ((void (^)())obj)();
                    }
                }
            }
            
            if([self.messageBarQueue count] > 0)
            {
                [self showNextMessage];
            }
            else
            {
                self.messageWindow = nil;
            }
        }];
    }
}

#pragma mark - Getters

- (UIView *)messageWindowView
{
    return [self messageBarViewController].view;
}

- (UIMessageBarViewController *)messageBarViewController
{
    if (!self.messageWindow)
    {
        self.messageWindow = [[UIMessageWindow alloc] init];
        self.messageWindow.frame = [UIApplication sharedApplication].keyWindow.frame;
        self.messageWindow.hidden = NO;
        self.messageWindow.windowLevel = UIWindowLevelNormal;
        self.messageWindow.backgroundColor = [UIColor clearColor];
        self.messageWindow.rootViewController = [[UIMessageBarViewController alloc] init];
    }
    return (UIMessageBarViewController *)self.messageWindow.rootViewController;
}

- (NSArray *)accessibleElements
{
    if (_accessibleElements != nil)
    {
        return _accessibleElements;
    }
    _accessibleElements = [NSArray array];
    return _accessibleElements;
}

#pragma mark - Setters

- (void)setStyleSheet:(NSObject<UIMessageBarStyleSheet> *)styleSheet
{
    if (styleSheet != nil)
    {
        _styleSheet = styleSheet;
    }
}

#pragma mark - TWMessageViewDelegate

- (NSObject<UIMessageBarStyleSheet> *)styleSheetForMessageView:(UIMessageView *)messageView
{
    return self.styleSheet;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger)accessibilityElementCount
{
    return (NSInteger)[self.accessibleElements count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [self.accessibleElements objectAtIndex:(NSUInteger)index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return (NSInteger)[self.accessibleElements indexOfObject:element];
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

@end

@implementation UIMessageView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [UIMessageView class])
	{
        // Fonts
        kTWMessageViewTitleFont = [UIFont boldSystemFontOfSize:16.0];
        kTWMessageViewDescriptionFont = [UIFont systemFontOfSize:14.0];
        
        // Colors
        kTWMessageViewTitleColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        kTWMessageViewDescriptionColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	}
}

- (id)initWithTitle:(NSString *)title description:(NSString *)description type:(UIMessageBarMessageType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        
        _titleString = title;
        _descriptionString = description;
        _messageType = type;
        
        _hasCallback = NO;
        _hit = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeDeviceOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<UIMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];
        
        // background fill
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(backgroundColorForMessageType:)])
            {
                [[styleSheet backgroundColorForMessageType:self.messageType] set];
                CGContextFillRect(context, rect);
            }
        }
        CGContextRestoreGState(context);
        
        // bottom stroke
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(strokeColorForMessageType:)])
            {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 0, rect.size.height);
                CGContextSetStrokeColorWithColor(context, [styleSheet strokeColorForMessageType:self.messageType].CGColor);
                CGContextSetLineWidth(context, 1.0);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
                CGContextStrokePath(context);
            }
        }
        CGContextRestoreGState(context);
        
        CGFloat xOffset = kTWMessageViewBarPadding;
        CGFloat yOffset = kTWMessageViewBarPadding + [self statusBarOffset];
        
        // icon
        CGContextSaveGState(context);
        {
            if ([styleSheet respondsToSelector:@selector(iconImageForMessageType:)])
            {
                [[styleSheet iconImageForMessageType:self.messageType] drawInRect:CGRectMake(xOffset, yOffset, kTWMessageViewIconSize, kTWMessageViewIconSize)];
            }
        }
        CGContextRestoreGState(context);
        
        yOffset -= kTWMessageViewTextOffset;
        xOffset += kTWMessageViewIconSize + kTWMessageViewBarPadding;
        
        CGSize titleLabelSize = [self titleSize];
        CGSize descriptionLabelSize = [self descriptionSize];
        
        if (self.titleString && !self.descriptionString)
        {
            yOffset = ceil(rect.size.height * 0.5) - ceil(titleLabelSize.height * 0.5) - kTWMessageViewTextOffset;
        }
        
        if ([[UIDevice currentDevice] isRunningiOS7OrLater])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.alignment = NSTextAlignmentLeft;
            
            [[self titleColor] set];
            [self.titleString drawWithRect:CGRectMake(xOffset, yOffset, titleLabelSize.width, titleLabelSize.height)
                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                attributes:@{NSFontAttributeName:[self titleFont], NSForegroundColorAttributeName:[self titleColor], NSParagraphStyleAttributeName:paragraphStyle}
                                   context:nil];
            
            yOffset += titleLabelSize.height;
            
            [[self descriptionColor] set];
            [self.descriptionString drawWithRect:CGRectMake(xOffset, yOffset, descriptionLabelSize.width, descriptionLabelSize.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                      attributes:@{NSFontAttributeName:[self descriptionFont], NSForegroundColorAttributeName:[self descriptionColor], NSParagraphStyleAttributeName:paragraphStyle}
                                         context:nil];
        }
        else
        {
            [[self titleColor] set];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.titleString drawInRect:CGRectMake(xOffset, yOffset, titleLabelSize.width, titleLabelSize.height) withFont:[self titleFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
#pragma clang diagnostic pop
            
            yOffset += titleLabelSize.height;
            
            [[self descriptionColor] set];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.descriptionString drawInRect:CGRectMake(xOffset, yOffset, descriptionLabelSize.width, descriptionLabelSize.height) withFont:[self descriptionFont] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
#pragma clang diagnostic pop
        }
    }
}

#pragma mark - Getters

- (CGFloat)height
{
    CGSize titleLabelSize = [self titleSize];
    CGSize descriptionLabelSize = [self descriptionSize];
    return MAX((kTWMessageViewBarPadding * 2) + titleLabelSize.height + descriptionLabelSize.height + [self statusBarOffset], (kTWMessageViewBarPadding * 2) + kTWMessageViewIconSize + [self statusBarOffset]);
}

- (CGFloat)width
{
    return [self statusBarFrame].size.width;
}

- (CGFloat)statusBarOffset
{
    return [[UIDevice currentDevice] isRunningiOS7OrLater] ? [self statusBarFrame].size.height : 0.0;
}

- (CGFloat)availableWidth
{
    return ([self width] - (kTWMessageViewBarPadding * 3) - kTWMessageViewIconSize);
}

- (CGSize)titleSize
{
    CGSize boundedSize = CGSizeMake([self availableWidth], CGFLOAT_MAX);
    CGSize titleLabelSize;
    
    if ([[UIDevice currentDevice] isRunningiOS7OrLater])
    {
        NSDictionary *titleStringAttributes = [NSDictionary dictionaryWithObject:[self titleFont] forKey: NSFontAttributeName];
        titleLabelSize = [self.titleString boundingRectWithSize:boundedSize
                                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:titleStringAttributes
                                                        context:nil].size;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        titleLabelSize = [_titleString sizeWithFont:[self titleFont] constrainedToSize:boundedSize lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
    }
    
    return CGSizeMake(ceilf(titleLabelSize.width), ceilf(titleLabelSize.height));
}

- (CGSize)descriptionSize
{
    CGSize boundedSize = CGSizeMake([self availableWidth], CGFLOAT_MAX);
    CGSize descriptionLabelSize;
    
    if ([[UIDevice currentDevice] isRunningiOS7OrLater])
    {
        NSDictionary *descriptionStringAttributes = [NSDictionary dictionaryWithObject:[self descriptionFont] forKey: NSFontAttributeName];
        descriptionLabelSize = [self.descriptionString boundingRectWithSize:boundedSize
                                                                    options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:descriptionStringAttributes
                                                                    context:nil].size;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        descriptionLabelSize = [_descriptionString sizeWithFont:[self descriptionFont] constrainedToSize:boundedSize lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
    }
    
    return CGSizeMake(ceilf(descriptionLabelSize.width), ceilf(descriptionLabelSize.height));
}

- (CGRect)statusBarFrame
{
    CGRect windowFrame = [self orientFrame:[UIApplication sharedApplication].keyWindow.frame];
    CGRect statusFrame = [self orientFrame:[UIApplication sharedApplication].statusBarFrame];
    return CGRectMake(windowFrame.origin.x, windowFrame.origin.y, windowFrame.size.width, statusFrame.size.height);
}

- (UIFont *)titleFont
{
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<UIMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];
        if ([styleSheet respondsToSelector:@selector(titleFontForMessageType:)])
        {
            return [styleSheet titleFontForMessageType:self.messageType];
        }
    }
    return kTWMessageViewTitleFont;
}

- (UIFont *)descriptionFont
{
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<UIMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];
        if ([styleSheet respondsToSelector:@selector(descriptionFontForMessageType:)])
        {
            return [styleSheet descriptionFontForMessageType:self.messageType];
        }
    }
    return kTWMessageViewDescriptionFont;
}

- (UIColor *)titleColor
{
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<UIMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];
        if ([styleSheet respondsToSelector:@selector(titleColorForMessageType:)])
        {
            return [styleSheet titleColorForMessageType:self.messageType];
        }
    }
    return kTWMessageViewTitleColor;
}

- (UIColor *)descriptionColor
{
    if ([self.delegate respondsToSelector:@selector(styleSheetForMessageView:)])
    {
        id<UIMessageBarStyleSheet> styleSheet = [self.delegate styleSheetForMessageView:self];
        if ([styleSheet respondsToSelector:@selector(descriptionColorForMessageType:)])
        {
            return [styleSheet descriptionColorForMessageType:self.messageType];
        }
    }
    return kTWMessageViewDescriptionColor;
}

#pragma mark - Helpers

- (CGRect)orientFrame:(CGRect)frame
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) || UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    }
    return frame;
}

#pragma mark - Notifications

- (void)didChangeDeviceOrientation:(NSNotification *)notification
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self statusBarFrame].size.width, self.frame.size.height);
    [self setNeedsDisplay];
}

@end

@implementation UIDefaultMessageBarStyleSheet

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [UIDefaultMessageBarStyleSheet class])
	{
        // Colors (background)
        kTWDefaultMessageBarStyleSheetErrorBackgroundColor = [UIColor colorWithRed:1.0 green:0.611 blue:0.0 alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // orange
        kTWDefaultMessageBarStyleSheetSuccessBackgroundColor = [UIColor colorWithRed:0.0f green:0.831f blue:0.176f alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // green
       // kTWDefaultMessageBarStyleSheetInfoBackgroundColor = [UIColor colorWithRed:0.0 green:0.482 blue:1.0 alpha:kTWMessageBarStyleSheetMessageBarAlpha]; // blue
        kTWDefaultMessageBarStyleSheetInfoBackgroundColor = [UIColor grayColor]; // blue
        
        // Colors (stroke)
        kTWDefaultMessageBarStyleSheetErrorStrokeColor = [UIColor colorWithRed:0.949f green:0.580f blue:0.0f alpha:1.0f]; // orange
        kTWDefaultMessageBarStyleSheetSuccessStrokeColor = [UIColor colorWithRed:0.0f green:0.772f blue:0.164f alpha:1.0f]; // green
       // kTWDefaultMessageBarStyleSheetInfoStrokeColor = [UIColor colorWithRed:0.0f green:0.415f blue:0.803f alpha:1.0f]; // blue
        
         kTWDefaultMessageBarStyleSheetInfoStrokeColor = [UIColor lightGrayColor]; // blue
        
    }
}

+ (UIDefaultMessageBarStyleSheet *)styleSheet
{
    return [[UIDefaultMessageBarStyleSheet alloc] init];
}

#pragma mark - TWMessageBarStyleSheet

- (UIColor *)backgroundColorForMessageType:(UIMessageBarMessageType)type
{
    UIColor *backgroundColor = nil;
    switch (type)
    {
        case UIMessageBarMessageTypeError:
            backgroundColor = kTWDefaultMessageBarStyleSheetErrorBackgroundColor;
            break;
        case UIMessageBarMessageTypeSuccess:
            backgroundColor = kTWDefaultMessageBarStyleSheetSuccessBackgroundColor;
            break;
        case UIMessageBarMessageTypeInfo:
            backgroundColor = kTWDefaultMessageBarStyleSheetInfoBackgroundColor;
            break;
        default:
            break;
    }
    return backgroundColor;
}

- (UIColor *)strokeColorForMessageType:(UIMessageBarMessageType)type
{
    UIColor *strokeColor = nil;
    switch (type)
    {
        case UIMessageBarMessageTypeError:
            strokeColor = kTWDefaultMessageBarStyleSheetErrorStrokeColor;
            break;
        case UIMessageBarMessageTypeSuccess:
            strokeColor = kTWDefaultMessageBarStyleSheetSuccessStrokeColor;
            break;
        case UIMessageBarMessageTypeInfo:
            strokeColor = kTWDefaultMessageBarStyleSheetInfoStrokeColor;
            break;
        default:
            break;
    }
    return strokeColor;
}

- (UIImage *)iconImageForMessageType:(UIMessageBarMessageType)type
{
    UIImage *iconImage = nil;
    switch (type)
    {
        case UIMessageBarMessageTypeError:
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconError];
            break;
        case UIMessageBarMessageTypeSuccess:
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconSuccess];
            break;
        case UIMessageBarMessageTypeInfo:
            iconImage = [UIImage imageNamed:kTWMessageBarStyleSheetImageIconInfo];
            break;
        default:
            break;
    }
    return iconImage;
}

@end

@implementation UIMessageWindow

#pragma mark - Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    /*
     * Pass touches through if they land on the rootViewController's view.
     * Allows notification interaction without blocking the window below.
     */
    if ([hitView isEqual: self.rootViewController.view])
    {
        hitView = nil;
    }
    
    return hitView;
}

@end

@implementation UIDevice (Additions)

#pragma mark - OS Helpers

- (BOOL)isRunningiOS7OrLater
{
    NSString *systemVersion = self.systemVersion;
    NSUInteger systemInt = [systemVersion intValue];
    return systemInt >= kTWMessageViewiOS7Identifier;
}

@end

@implementation UIMessageBarViewController

#pragma mark - Setters

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
    
    if ([[UIDevice currentDevice] isRunningiOS7OrLater])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;

    if ([[UIDevice currentDevice] isRunningiOS7OrLater])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

@end
