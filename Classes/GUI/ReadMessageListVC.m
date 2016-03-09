//
//  ReadMessageListVC.m
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "ReadMessageListVC.h"
#import "ReadMessagesListCell.h"
#import "DBMessage+Methods.h"
#import "DBUser+Methods.h"
#import "Model.h"
#import "ReadMessageVC.h"
#import "MyMessagesManager.h"
#import "DateUtils.h"

@implementation ReadMessageListVC

- (void) viewDidLoad
{
    [super viewDidLoad];
	[(UIScrollView*)self.view setContentSize:CGSizeMake(320, 400)];
    self.view.backgroundColor = [UIColor colorWithRed:(245.0 / 255.0) green:(245.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Message history"]];
    
    // resize table image
    UIImage* selectTableImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeTableImage = [selectTableImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.tableImage.image = resizeTableImage;
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    messages = [[NSMutableArray alloc] initWithArray:[DELEGATE.me.messages allObjects]];
    [messages sortUsingSelector:@selector(sortByDate:)];
}

- (void) viewDidUnload
{
    [self setLabelUnreadMessagesCount:nil];
    [self setLabelAllMessagesCount:nil];
    [self setTable:nil];
    
    [super viewDidUnload];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	MyMessagesManager* manager = [Model sharedInstance].myMessages;
	self.labelAllMessagesCount.text = [NSString stringWithFormat:@"Messages count: %d", [messages count]];
	self.labelUnreadMessagesCount.text = [NSString stringWithFormat:@"Unread messages count: %d", [[manager unreadMessages] count]];
    
	[self.table reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBMessage* message = [messages objectAtIndex:[indexPath row]];
    
    NSString* text = message.text;
    
    NSRange range = [text rangeOfString:@"gow share marker message:"];
    if (range.location != NSNotFound)
    {
        // add marker on map;
        NSMutableString* template1 = [NSMutableString stringWithString:text];
        [template1 replaceCharactersInRange:range withString:@""];
        
        NSRange comma1Range = [template1 rangeOfString:@","];
        
        NSMutableString* longitude = [NSMutableString stringWithString:template1];
        [longitude deleteCharactersInRange:NSMakeRange(comma1Range.location, [template1 length] - comma1Range.location)];
        [template1 deleteCharactersInRange:NSMakeRange(0, comma1Range.location + 1)];
        
        NSMutableString* template2 = [NSMutableString stringWithString:template1];
        NSRange comma2Range = [template2 rangeOfString:@","];
        
        NSMutableString* latitude = [NSMutableString stringWithString:template2];
        [latitude deleteCharactersInRange:NSMakeRange(comma2Range.location, [template2 length] - comma2Range.location)];
        
        NSMutableString* text = [NSMutableString stringWithString:template2];
        [text deleteCharactersInRange:NSMakeRange(0, comma2Range.location + 1)];

        message.isUnread = [NSNumber numberWithBool:NO];
        
        NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:longitude, @"longitude", latitude, @"latitude", text, @"text", nil];
        
        [self.delegate performSelector:@selector(didReadSharedMarker:) withObject:parameters];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"ReadMessage" sender:message];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(DBMessage*)sender
{
	ReadMessageVC* vc = (ReadMessageVC*)segue.destinationViewController;
	vc.message = sender;
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [messages count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"ReadMessagesListCell_%d", index];
	ReadMessagesListCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
    {
        cell = [[ReadMessagesListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
	
	DBMessage* message = [messages objectAtIndex:[indexPath row]];
    
    NSString* text = message.text;
    if ([text rangeOfString:@"gow share marker message:"].location != NSNotFound)
    {
        text = @"Shared Marker";
    }
	
    DBUser* user = message.from;
    cell.labelUsername.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
	cell.labelMessage.text = text;
	
	cell.labelDate.text = [DateUtils stringFromDate:message.friendlyDate];
	float size = cell.labelDate.font.pointSize;
	cell.labelDate.font = [message.isUnread boolValue] ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
	cell.labelDate.textColor = [message.isUnread boolValue] ? [UIColor blackColor] : [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
	
	return cell;
}

@end
