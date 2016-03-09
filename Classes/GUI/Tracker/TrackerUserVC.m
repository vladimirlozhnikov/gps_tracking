//
//  UserVC.m
//  GPSTracker
//
//  Created by YS on 2/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerUserVC.h"
#import "DBMessage+Methods.h"
#import "DBUser+Methods.h"
#import "Model.h"
#import "ImageUtils.h"
#import "DBGroup+Methods.h"

@interface TrackerUserVC()

@property(nonatomic) UIImage* image;

@end

@implementation TrackerUserVC

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onTakePhoto
{
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		return;
	
	UIImagePickerController* vc = [UIImagePickerController new];
	vc.delegate = self;
	vc.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentViewController:vc animated:YES completion:^(){}];
}

- (IBAction) onSelectPhoto
{
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        return;
    }
	
	UIImagePickerController* vc = [UIImagePickerController new];
	vc.delegate = self;
	vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:vc animated:YES completion:^(){}];
}

- (void) sendWithDelayInMainThread
{
    //NSLog(@"sendWithDelayInMainThread");
    DBMessage* message = [DBMessage messageWithText:self.textView.text image:self.image priority:MessagePriorityNormal user:DELEGATE.me];
    
	[self.group sendMessage:message toUsers:@[self.user] onSuccess:^()
     {
         [DELEGATE hideActivity];
         [DELEGATE showAlertWithBlock:^(NSUInteger clickedButton)
          {
              [self onClose:nil];
          }
                              message:@"Send successfully" buttons:@"OK", nil];
     } onError:^(NSString* error)
     {
         [DELEGATE hideActivity];
         [DELEGATE showAlertWithMessage:error];
     }];
}

- (void) sendWithDelay
{
    [self performSelectorOnMainThread:@selector(sendWithDelayInMainThread) withObject:nil waitUntilDone:NO];
}

- (IBAction) onSend
{
	[DELEGATE showActivity];
    [self performSelector:@selector(sendWithDelay) withObject:nil afterDelay:0.5];
}

- (IBAction) onRemovePhoto
{
	self.image = nil;
	self.buttonAttachment.hidden = YES;
}

- (IBAction) telClicked:(id)sender
{
    if ([self.user.phoneNumber length] > 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.user.phoneNumber]]];
    }
}

- (void) viewDidUnload
{
	[self setImagePhoto:nil];
	[self setTextView:nil];
	[self setScrollView:nil];
	[self setLabelFirstName:nil];
	[self setLabelLastName:nil];
	[self setLabelNickname:nil];
	[self setLabelPhone:nil];
	[self setButtonSendMessage:nil];
	[self setButtonAttachment:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self.scrollView setContentSize:CGSizeMake(320, 600)];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"User information"]];
    
    // resize message background
    UIImage* selectMessageImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeMessageColorImage = [selectMessageImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.messageImage.image = resizeMessageColorImage;
    
    // resize make photo image
    UIImage* normalMakePhotoImage = [UIImage imageNamed:@"cell.png"];
    UIImage* highlightedMakePhotoImage = [UIImage imageNamed:@"cell_pres.png"];
    UIImage* resizeNormalMakePhotoImage = [normalMakePhotoImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage* resizeHighlightedMakePhotoImage = [highlightedMakePhotoImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    [self.buttonMakePhoto setBackgroundImage:resizeNormalMakePhotoImage forState:UIControlStateNormal];
    [self.buttonMakePhoto setBackgroundImage:resizeHighlightedMakePhotoImage forState:UIControlStateHighlighted];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
    //singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imagePhoto setUserInteractionEnabled:YES];
    [self.imagePhoto addGestureRecognizer:singleTap];
}

- (void)bannerTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.user.index isEqualToString:DELEGATE.me.index])
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            return;
        }
        
        isAvatarAssiged = YES;
        UIImagePickerController* vc = [UIImagePickerController new];
        vc.delegate = self;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:vc animated:YES completion:^(){}];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!_isInited)
	{
		self.buttonAttachment.hidden = YES;
		self.labelFirstName.text = self.user.firstName;
		self.labelLastName.text = self.user.lastName;
		self.labelNickname.text = self.user.nickName;
		self.labelPhone.text = self.user.phoneNumber;
        
        if ([self.user.imageUrl length] > 0)
        {
            [self.user imageInBackground:self.imagePhoto];
        }
		
		_isInited = YES;
	}
    
    BOOL hidden = [self.user.index isEqualToString:DELEGATE.me.index];
    self.buttonMakePhoto.hidden = hidden;
    self.buttonSendMessage.hidden = hidden;
    self.messageImage.hidden = hidden;
    self.textView.hidden = hidden;
}

#pragma UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (isAvatarAssiged)
    {
        [DELEGATE showActivity];
        
        self.imagePhoto.hidden = NO;
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imagePhoto.image = img;
        [self dismissViewControllerAnimated:YES completion:^(){
            DELEGATE.me.imageAvatar = nil;
            UIImage* lowImage = [ImageUtils imageWithLowQuality:img];
            DELEGATE.me.imageAvatar = UIImageJPEGRepresentation(lowImage, 0);
            
            [DELEGATE.me updateWithSuccess:^{
                [DELEGATE hideActivity];
                
                [self onClose:nil];
            } onError:^(NSString *error) {
                [DELEGATE hideActivity];
                [DELEGATE showAlertWithMessage:error];
            }];
        }];
    }
    else
    {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.buttonAttachment.hidden = NO;
        [self dismissViewControllerAnimated:YES completion:^(){}];
    }
    
    isAvatarAssiged = NO;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark UITextViewDelegate
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
	{
        [textView resignFirstResponder];
        
        return NO;
    }
	else
	{
		BOOL bFirstFilled = ([textView.text length] + [text length] - range.length) > 0;
		self.buttonSendMessage.enabled = bFirstFilled;
        
		return YES;
	}
}

@end
