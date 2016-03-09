//
//  SendMessageVC.m
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "AlertMessageVC.h"
#import "Model.h"
#import "AlertMessageCell.h"
#import "DBGroup+Methods.h"

@interface AlertMessageVC()

@property(nonatomic) Settings* settings;

@end

@implementation AlertMessageVC

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onSelectPhoto
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        return;
    }
	
	UIImagePickerController* vc = [UIImagePickerController new];
	vc.delegate = self;
	vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:vc animated:YES completion:^(){}];
}

- (IBAction) onSend
{
	[DELEGATE showActivity];
		
	NSMutableArray* usersWithoutMe = [self.users mutableCopy];
	[usersWithoutMe removeObjectIdenticalTo:DELEGATE.me];
	
	DBMessage* message = [DBMessage messageWithText:self.textFieldMessage.text image:self.imagePhoto.image priority:MessagePriorityNormal user:DELEGATE.me];
	[self.group sendMessage:message toUsers:usersWithoutMe onSuccess:^()
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithBlock:^(NSUInteger clickedButton)
		{
			[self onClose:nil];
		}
		message:@"Send successfully" buttons:@"OK", nil];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];		
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) viewDidUnload
{
    [self setTextFieldMessage:nil];
	[self setImagePhoto:nil];
    [self setTable:nil];
	[self setButtonSend:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
    ((UIScrollView*)self.view).contentSize = CGSizeMake(320.0, 500.0);
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Alert message"]];
    
    // resize table image
    UIImage* selectTableImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeTableImage = [selectTableImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.tableImage.image = resizeTableImage;
    
    // resize attach image
    UIImage* selectAttachImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeAttachImage = [selectAttachImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.attachImage.image = resizeAttachImage;
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![self.textFieldMessage.text length])
    {
        self.buttonSend.enabled = NO;
    }
}

- (IBAction) onRemovePhoto
{
	self.imagePhoto.image = nil;
	self.buttonAttachment.hidden = YES;
}

#pragma UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.buttonAttachment.hidden = NO;
	self.imagePhoto.image = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL isFilled = ([textField.text length] + [string length] - range.length) > 0;
	self.buttonSend.enabled = isFilled;
    
	return YES;
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[Model sharedInstance].settings.alertTemplates count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"AlertMessageCell_%d", index];
	AlertMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
    {
        cell = [[AlertMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
	
	cell.labelMessage.text = [[Model sharedInstance].settings.alertTemplates objectAtIndex:[indexPath row]];
	cell.imageTick.hidden = YES;
    
	return cell;
}

#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	AlertMessageCell* cell = (AlertMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
    
	cell.imageTick.hidden = NO;
	cell.labelMessage.textColor = [UIColor blackColor];
	self.textFieldMessage.text = [[Model sharedInstance].settings.alertTemplates objectAtIndex:[indexPath row]];
	self.buttonSend.enabled = YES;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	AlertMessageCell* cell = (AlertMessageCell*)[tableView cellForRowAtIndexPath:indexPath];
	cell.imageTick.hidden = YES;
	cell.labelMessage.textColor = [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
}

@end
