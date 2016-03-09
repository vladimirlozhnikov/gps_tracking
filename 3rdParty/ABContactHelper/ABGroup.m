/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABGroup.h"
#import "ABContactsHelper.h"

#define CFAutorelease(obj) ({CFTypeRef _obj = (obj); (_obj == NULL) ? NULL : [(id)CFMakeCollectable(_obj) autorelease]; })

@implementation ABGroup
@synthesize record;

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
	if (self = [super init]) record = CFRetain(aRecord);
	return self;
}

+ (id) groupWithRecord: (ABRecordRef) grouprec
{
	return [[ABGroup alloc] initWithRecord:grouprec];
}

+ (id) groupWithRecordID: (ABRecordID) recordID
{
	ABAddressBookRef addressBook = [ABContactsHelper addressBook];
	ABRecordRef grouprec = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
	ABGroup *group = [self groupWithRecord:grouprec];
	return group;
}

// Thanks to Ciaran
+ (id) group
{
	ABRecordRef grouprec = ABGroupCreate();
	id group = [ABGroup groupWithRecord:grouprec];
	CFRelease(grouprec);
	return group;
}

- (void) dealloc
{
	if (record) CFRelease(record);
}

- (BOOL) removeSelfFromAddressBook: (NSError **) error
{
	CFErrorRef cfError;
	ABAddressBookRef addressBook = [ABContactsHelper addressBook];
	if (!ABAddressBookRemoveRecord(addressBook, self.record, &cfError)) return NO;
	BOOL result = ABAddressBookSave(addressBook, &cfError);
	if(error)
		*error = CFBridgingRelease(cfError);
	return result;
}

#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark management
- (NSArray *) members
{
	NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembers(self.record);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
	for (id contact in contacts)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
	return array;
}

// kABPersonSortByFirstName = 0, kABPersonSortByLastName  = 1
- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering
{
	NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(self.record, ordering);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
	for (id contact in contacts)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)contact]];
	return array;
}

- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error
{
	CFErrorRef cfError;
	BOOL result = ABGroupAddMember(self.record, contact.record, &cfError);
	if(error)
		*error = CFBridgingRelease(cfError);
	return result;
}

- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error
{
	CFErrorRef cfError;
	BOOL result = ABGroupRemoveMember(self.record, contact.record, &cfError);
	if(error)
		*error = CFBridgingRelease(cfError);
	return result;
}

#pragma mark name

- (NSString *) getRecordString:(ABPropertyID) anID
{
	return (__bridge_transfer NSString *) ABRecordCopyValue(record, anID);
}

- (NSString *) name
{
	NSString *string = [self getRecordString:kABGroupNameProperty];
	return string;
}

- (void) setName: (NSString *) aString
{
	CFErrorRef error;
	BOOL success = ABRecordSetValue(record, kABGroupNameProperty, (__bridge CFStringRef) aString, &error);
	if (!success) NSLog(@"Error: %@", [(__bridge NSError *)error localizedDescription]);
}
@end
