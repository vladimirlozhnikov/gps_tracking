//
//  PPDbManager.h
//  PatientProgress
//
//  Created by vladimir.lozhnikov on 21.02.13.
//  Copyright (c) 2013 intellectsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PPDbManager : NSObject
{
}

// common methods
+ (id) objectForEntityName:(NSString*)entityName;
+ (id) itemForEntitiNameAndCriteria:(NSString*)entityName withCriteria:(NSString*)criteria;
+ (NSArray*) loadAllItemsForName:(NSString*)entityName withCriteria:(NSString*)criteria;
+ (NSArray*) loadAllItemsOfEntity:(NSEntityDescription*)entity withPredicate:(NSPredicate*)predicate;
+ (void) removeObject:(NSManagedObject*)object;

+ (void) save;
+ (void) rollback;

@end
