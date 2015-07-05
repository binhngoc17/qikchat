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
#import "QikAChat-Prefix.pch"

@interface SettingsViewController()
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableDictionary *tableDictionory;
@end

@implementation SettingsViewController


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
}


- (void) initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    
    [self.tableView setBackgroundColor:dClearColor];
    [[UITableViewHeaderFooterView appearance] setTintColor:dHeaderColor];
    
    self.tableDictionory  = [[NSMutableDictionary alloc] init];
    
    NSArray* arry1 = [[NSArray alloc] initWithObjects:@"Account",@"Profile",@"Status",nil];
    [self.tableDictionory setObject:arry1 forKey:@"My Data"];
    
    NSArray* arry2 = [[NSArray alloc] initWithObjects:@"Sound",@"Wallpaper",@"Notification",nil];
    [self.tableDictionory setObject:arry2 forKey:@"Chats"];
  
    NSArray* arry3 = [[NSArray alloc] initWithObjects:@"Share",@"Block",nil];
    [self.tableDictionory setObject:arry3 forKey:@"Friends"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Settings";
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
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.tableDictionory allKeys] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    return [[self.tableDictionory allKeys] objectAtIndex:sectionIndex] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSString* key = [[self.tableDictionory allKeys] objectAtIndex:sectionIndex] ;
    NSArray* list = [self.tableDictionory objectForKey:key];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
     }
    
    NSString* key = [[self.tableDictionory allKeys] objectAtIndex:indexPath.section] ;
    NSArray* list = [self.tableDictionory objectForKey:key];
    
    cell.textLabel.text = [NSString stringWithFormat:@"\t%@",[list objectAtIndex:indexPath.row]];
    
    [cell setBackgroundColor:dTableCellColor];
    cell.layer.borderColor = dHeaderColor.CGColor;
    cell.layer.borderWidth = 1.0f;

    return cell;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    // this is just for demo purpose
    
    NSString* key = [[self.tableDictionory allKeys] objectAtIndex:indexPath.section] ;
    NSArray* list = [self.tableDictionory objectForKey:key];
    NSString* rowText =  [list objectAtIndex:indexPath.row];
    
    NSString* formatStr = [NSString stringWithFormat:@"You Selected : %@ -> %@", key, rowText ];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported Yet"
                                                    message:formatStr
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    [alert show];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
