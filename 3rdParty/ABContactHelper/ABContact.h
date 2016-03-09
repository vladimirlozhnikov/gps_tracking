/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABContact : NSObject
{
	ABRecordRef record;
}

// Convenience allocation methods
+ (id) contact;
+ (id) contactWithRecord: (ABRecordRef) record;
+ (id) contactWithRecordID: (ABRecordID) recordID;

// Class utility methods
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty;
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty;
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty;
+ (NSString *) propertyString: (ABPropertyID) aProperty;
+ (BOOL) propertyIsMultivalue: (ABPropertyID) aProperty;
+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;
+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;

// Creating proper dictionaries
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code;
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName;

// Instance utility methods
- (BOOL) removeSelfFromAddressBook: (NSError **) error;

@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (nonatomic, weak) NSString *firstname;
@property (nonatomic, weak) NSString *lastname;
@property (nonatomic, weak) NSString *middlename;
@property (nonatomic, weak) NSString *prefix;
@property (nonatomic, weak) NSString *suffix;
@property (nonatomic, weak) NSString *nickname;
@property (nonatomic, weak) NSString *firstnamephonetic;
@property (nonatomic, weak) NSString *lastnamephonetic;
@property (nonatomic, weak) NSString *middlenamephonetic;
@property (nonatomic, weak) NSString *organization;
@property (nonatomic, weak) NSString *jobtitle;
@property (nonatomic, weak) NSString *department;
@property (nonatomic, weak) NSString *note;

@property (weak, readonly) NSString *contactName; // my friendly utility
@property (weak, readonly) NSString *compositeName; // via AB

#pragma mark NUMBER
@property (nonatomic, weak) NSNumber *kind;

#pragma mark DATE
@property (nonatomic, weak) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSDate *modificationDate;

#pragma mark MULTIVALUE
// Each of these produces an array of NSStrings
@property (nonatomic, strong, readonly) NSArray *emailArray;
@property (nonatomic, strong, readonly) NSArray *emailLabels;
@property (nonatomic, strong, readonly) NSArray *phoneArray;
@property (nonatomic, strong, readonly) NSArray *phoneLabels;
@property (nonatomic, strong, readonly) NSArray *relatedNameArray;
@property (nonatomic, strong, readonly) NSArray *relatedNameLabels;
@property (nonatomic, strong, readonly) NSArray *urlArray;
@property (nonatomic, strong, readonly) NSArray *urlLabels;
@property (nonatomic, strong, readonly) NSArray *dateArray;
@property (nonatomic, strong, readonly) NSArray *dateLabels;
@property (nonatomic, strong, readonly) NSArray *addressArray;
@property (nonatomic, strong, readonly) NSArray *addressLabels;
@property (nonatomic, strong, readonly) NSArray *smsArray;
@property (nonatomic, strong, readonly) NSArray *smsLabels;

@property (nonatomic, strong, readonly) NSString *emailaddresses;
@property (nonatomic, strong, readonly) NSString *phonenumbers;
@property (nonatomic, strong, readonly) NSString *urls;

// Each of these uses an array of dictionaries
@property (nonatomic, weak) NSArray *emailDictionaries;
@property (nonatomic, weak) NSArray *phoneDictionaries;
@property (nonatomic, weak) NSArray *relatedNameDictionaries;
@property (nonatomic, weak) NSArray *urlDictionaries;
@property (nonatomic, weak) NSArray *dateDictionaries;
@property (nonatomic, weak) NSArray *addressDictionaries;
@property (nonatomic, weak) NSArray *smsDictionaries;

#pragma mark IMAGES
@property (nonatomic, weak) UIImage *image;

#pragma mark REPRESENTATIONS

// Conversion to dictionary
- (NSDictionary *) baseDictionaryRepresentation; // no image
- (NSDictionary *) dictionaryRepresentation; // image where available

// Conversion to data
- (NSData *) baseDataRepresentation; // no image
- (NSData *) dataRepresentation; // image where available

+ (id) contactWithDictionary: (NSDictionary *) dict;
+ (id) contactWithData: (NSData *) data;
@end