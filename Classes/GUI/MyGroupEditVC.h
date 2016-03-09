//
//  MyGroupEditVC.h
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyGroupEditCell.h"
#import "ContactsMultiPickerVC.h"
#import "Protocol.h"

@class DBGroup;
@class SelectionVC;
@class DBCountry;
@class DBCity;

@interface MyGroupEditVC : BaseVC<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, AddressBookProtocol, ContactsMultiPickerVCDelegate>
{
	enum
	{
		MyGroupEditModeCountry = 0,
		MyGroupEditModeCity,
		MyGroupEditModeCount
	}_selectionMode;

	BOOL _isInitited;
	SelectionVC* _selectionVC;
	DBCountry* _country;
	DBCity* _city;
	NSMutableArray* _cities;
    NSMutableArray* _contacts;
	
	__strong UIColor* _colors[28];
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldNickName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UILabel* cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView* cityArrow;
@property (weak, nonatomic) IBOutlet UIButton* addManuallyButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageTickOpen;
@property (weak, nonatomic) IBOutlet UIImageView *imageTickClosed;
@property (weak, nonatomic) IBOutlet UIImageView* descriptionImage;
@property (weak, nonatomic) IBOutlet UIImageView* contactsImage;

@property (weak, nonatomic) IBOutlet UITextView *textViewDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpdate;

@property (weak, nonatomic) IBOutlet UIButton *buttonCountry;
@property (weak, nonatomic) IBOutlet UIButton *buttonCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCustomCity;

@property (weak, nonatomic) IBOutlet UIButton *buttonCreate;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEntryTicket;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@property (weak, nonatomic) DBGroup* group;

- (IBAction) onGroupOpen;
- (IBAction) onGroupClosed;

- (IBAction) onCountry;
- (IBAction) onCity;

- (IBAction) onCreate;
- (IBAction) onUpdate;
- (IBAction) onAddManually;

@end
