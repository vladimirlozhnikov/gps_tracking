//
//  RegistrationVC.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "RegistrationVC.h"
#import "Model.h"
#import "DBUser+Methods.h"
#import "ImageUtils.h"

@interface RegistrationVC()

@property(nonatomic) BOOL isAvatarAssigned;

@end

@implementation RegistrationVC

- (void) viewDidLoad
{
	[super viewDidLoad];
    
	for (UIButton* button in self.buttons)
	{
		UIImage* assignedImage = [button backgroundImageForState:UIControlStateNormal];
		UIImage* img = [assignedImage stretchableImageWithLeftCapWidth:-106 topCapHeight:25];
		[button setBackgroundImage:img forState:UIControlStateNormal];
	}
    
    ((UIScrollView*)self.view).contentSize = CGSizeMake(320.0, 480.0);
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Register/ Sign up"]];
    
    // resize select avatar background
    UIImage* selectAvatarImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeSelectAvatarImage = [selectAvatarImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.selectAvatarBackground.image = resizeSelectAvatarImage;
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];

}

- (void) viewDidUnload
{
    [self setTextFieldFirstName:nil];
    [self setTextFieldLastName:nil];
    [self setTextFieldNickname:nil];
    [self setTextFieldEmail:nil];
    [self setImageAvatar:nil];
	[self setTextFieldPhoneNumber:nil];
	[self setButtonSend:nil];
	[self setTextFields:nil];
	[self setImageAvatarBg:nil];
	[self setButtons:nil];
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.buttonSend.enabled = ([self.textFieldFirstName.text length] && [self.textFieldLastName.text length] && [self.textFieldEmail.text length]);
    
    self.trafficInLabel.text = [[Model sharedInstance].settings friendlyDownloadTraffic];
    self.trafficOutLabel.text = [[Model sharedInstance].settings friendlyUploadTraffic];
}

- (IBAction) onChooseAvatar
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

- (IBAction) onRegister
{
	[DELEGATE showActivity];
	DBUser* user = [DBUser userWithFirstName:self.textFieldFirstName.text lastName:self.textFieldLastName.text email:self.textFieldEmail.text];
	user.nickName = self.textFieldNickname.text;
	user.phoneNumber = self.textFieldPhoneNumber.text;
	
	if (self.isAvatarAssigned)
    {
        UIImage* lowImage = [ImageUtils imageWithLowQuality:self.imageAvatar.image];
        user.imageAvatar = UIImageJPEGRepresentation(lowImage, 0);
    }
	
	[user registerWithSuccess:^(NSDictionary* response)
	{
		[DELEGATE hideActivity];
		NSString* message = [NSString stringWithFormat:@"Registration successfully\nYou password is: %@", [Model sharedInstance].credentials.password];
		[DELEGATE showAlertWithBlock:^(NSUInteger clickedButton)
		{
			[self performSegueWithIdentifier:@"LoginVC" sender:self];
		}
         
		message:message buttons:@"OK", nil];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];		
		[DELEGATE showAlertWithMessage:error];
	} saveAvatar:YES];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.imageAvatarBg.image = [UIImage imageNamed:@"ava_box_2.png"];
	self.imageAvatar.hidden = NO;
	UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
	self.imageAvatar.image = img;
	self.isAvatarAssigned = YES;
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
	/*if (![self.textFields containsObject:textField])
    {
        return YES;
    }
	
	BOOL bFirstFilled = ([textField.text length] + [string length] - range.length) > 0;
	
	NSUInteger filledTextBoxes = 0;
	for (UITextField* textFieldCollection in self.textFields)
	{
		if(textFieldCollection != textField && [textFieldCollection.text length])
        {
            ++filledTextBoxes;
        }
	}
	
	self.buttonSend.enabled = (filledTextBoxes == 2 && bFirstFilled);*/
    BOOL bFirstFilled = ([textField.text length] + [string length] - range.length) > 0;
    
    self.buttonSend.enabled = bFirstFilled;
    if (textField != self.textFieldFirstName)
    {
        if ([self.textFieldFirstName.text length] == 0)
            self.buttonSend.enabled = NO;
    }
    
    if (textField != self.textFieldLastName)
    {
        if ([self.textFieldLastName.text length] == 0)
            self.buttonSend.enabled = NO;
    }
    
    if (textField != self.textFieldNickname)
    {
        if ([self.textFieldNickname.text length] == 0)
            self.buttonSend.enabled = NO;
    }
    
    NSString* emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (textField != self.textFieldEmail)
    {
        if ([self.textFieldEmail.text length] == 0)
        {
            self.buttonSend.enabled = NO;
        }
        else
        {
            BOOL valid = [test evaluateWithObject:[self.textFieldEmail.text lowercaseString]];
            if (!valid)
            {
                self.buttonSend.enabled = NO;
            }
        }
    }
    else if (bFirstFilled)
    {
        NSString* str = [self.textFieldEmail.text stringByReplacingCharactersInRange:range withString:string];
        BOOL valid = [test evaluateWithObject:[str lowercaseString]];
        if (!valid)
        {
            self.buttonSend.enabled = NO;
        }
    }
    
	return YES;
}

#pragma mark - TrafficProtocol

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload
{
    self.trafficInLabel.text = friendlyDownload;
    self.trafficOutLabel.text = friendlyUpload;
}

@end
