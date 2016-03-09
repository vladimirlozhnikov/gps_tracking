/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContactsHelper.h"

@implementation ABContactsHelper

ABAddressBookRef _addressBook = nil;

+ (ABAddressBookRef) addressBook
{
	if(!_addressBook)
    {
        if (![ABContactsHelper isABAddressBookCreateWithOptionsAvailable])
        {
            _addressBook = ABAddressBookCreate();
        }
        else
        {
            CFErrorRef error = nil;
            _addressBook = ABAddressBookCreateWithOptions(nil, &error);
        }
    }
	
	return _addressBook;
}

+ (BOOL) isABAddressBookCreateWithOptionsAvailable
{
    return (&ABAddressBookCreateWithOptions != NULL);
}

+ (void) contacts:(id<AddressBookProtocol>)sender
{
	ABAddressBookRef addressBook = [self addressBook];
    
    if (![ABContactsHelper isABAddressBookCreateWithOptionsAvailable])
    {
        NSArray *thePeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *contacts = [NSMutableArray array];
        for (id person in thePeople)
        {
            ABContact* contact = [ABContact contactWithRecord:(ABRecordRef)person];
            if (![contact.emailArray count])
                continue;
            
            [contacts addObject:contact];
        }
        
        //CFRelease(addressBook);
        [sender didGetContacts:contacts];
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // callback can occur in background, address book must be accessed on thread it was created on
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted)
                {
                    // access granted
                    NSArray* array = AddressBookUpdated(addressBook);
                    //CFRelease(addressBook);
                    
                    NSMutableArray *contacts = [NSMutableArray array];
                    for (ABContact* person in array)
                    {
                        if (![person.emailArray count])
                            continue;
                        
                        [contacts addObject:person];
                    }

                    
                    [sender didGetContacts:contacts];
                }
            });
        });
    }
}

NSArray* AddressBookUpdated(ABAddressBookRef addressBook)
{
    NSArray *thePeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
    for (id person in thePeople)
    {
        [array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
    }
    
    return array;
};

+ (int) contactsCount
{
	ABAddressBookRef addressBook = [self addressBook];
	return ABAddressBookGetPersonCount(addressBook);
}

+ (int) contactsWithImageCount
{
	ABAddressBookRef addressBook = [self addressBook];
	NSArray *peopleArray = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (ABPersonHasImageData((__bridge ABRecordRef)(person))) ncount++;
	return ncount;
}

+ (int) contactsWithoutImageCount
{
	ABAddressBookRef addressBook = [self addressBook];
	NSArray *peopleArray = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (!ABPersonHasImageData((__bridge ABRecordRef)(person))) ncount++;
	return ncount;
}

// Groups
+ (int) numberOfGroups
{
	ABAddressBookRef addressBook = [self addressBook];
	NSArray *groups = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	int ncount = groups.count;
	return ncount;
}

+ (NSArray *) groups
{
	ABAddressBookRef addressBook = [self addressBook];
	NSArray *groups = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:groups.count];
	for (id group in groups)
		[array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
	return array;
}

// Sorting
+ (BOOL) firstNameSorting
{
	return (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst);
}

#pragma mark Contact Management

// Thanks to Eridius for suggestions re: error
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error
{
	CFErrorRef cfError;
	ABAddressBookRef addressBook = [self addressBook];
	if (!ABAddressBookAddRecord(addressBook, aContact.record, (CFErrorRef *) &cfError))
	{
		if(error)
			*error = CFBridgingRelease(cfError);
		return NO;
	}
	BOOL result = ABAddressBookSave(addressBook, &cfError);
	if(error)
		*error = CFBridgingRelease(cfError);
	return result;
}

+ (BOOL) addGroup: (ABGroup *) aGroup withError: (NSError **) error
{
	CFErrorRef cfError;
	ABAddressBookRef addressBook = [self addressBook];
	if (!ABAddressBookAddRecord(addressBook, aGroup.record, &cfError))
	{
		if(error)
			*error = CFBridgingRelease(cfError);
		return NO;
	}
	BOOL result = ABAddressBookSave(addressBook, &cfError);
	if(error)
		*error = CFBridgingRelease(cfError);
	return result;
}

/*+ (NSArray *) contactsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	return contacts;
}

+ (NSArray *) contactsMatchingPhone: (NSString *) number
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
	return [contacts filteredArrayUsingPredicate:pred];
}*/

+ (NSArray *) groupsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *groups = [ABContactsHelper groups];
	pred = [NSPredicate predicateWithFormat:@"name contains[cd] %@ ", fname];
	return [groups filteredArrayUsingPredicate:pred];
}
@end