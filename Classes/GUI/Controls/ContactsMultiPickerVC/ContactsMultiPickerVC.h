//
//  TKContactsMultiPickerController.h
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <malloc/malloc.h>

@class TKContact, ContactsMultiPickerVC;
@protocol ContactsMultiPickerVCDelegate <NSObject>
@required
- (void)tkContactsMultiPickerController:(ContactsMultiPickerVC*)picker didFinishPickingDataWithInfo:(NSArray*)contacts;
- (void)tkContactsMultiPickerControllerDidCancel:(ContactsMultiPickerVC*)picker;
@end


@interface ContactsMultiPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
	__weak id _delegate;
	NSArray* _contacts;
    
@private
    NSUInteger _selectedCount;
    NSMutableArray *_listContent;
	NSMutableArray *_filteredListContent;
}

@property (nonatomic, weak) id<ContactsMultiPickerVCDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray* groups;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (id)initWithContacts:(NSArray*)contacts;

@end
