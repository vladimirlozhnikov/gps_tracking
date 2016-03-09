//
//  PPDbManager.m
//  PatientProgress
//
//  Created by vladimir.lozhnikov on 21.02.13.
//  Copyright (c) 2013 intellectsoft. All rights reserved.
//

#import "PPDbManager.h"
#import "AppDelegate.h"
#import "DBCity+Methods.h"
#import "DBColor+Methods.h"

@implementation PPDbManager

#pragma mark - Static Methods

+ (id) objectForEntityName:(NSString*)entityName
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObject* o = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:app.managedObjectContext];
    
    return o;
}

+ (id) itemForEntitiNameAndCriteria:(NSString*)entityName withCriteria:(NSString*)criteria
{
    NSArray* result = [PPDbManager loadAllItemsForName:entityName withCriteria:criteria];
    if ([result count] > 0)
    {
        return [result objectAtIndex:0];
    }
    
    return nil;
}

+ (NSArray*) loadAllItemsForName:(NSString*)entityName withCriteria:(NSString*)criteria
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray* items = nil;
    NSPredicate* predicate = nil;
    
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:app.managedObjectContext];
    if ([criteria length] > 0)
    {
        predicate = [NSPredicate predicateWithFormat:criteria];
    }
    
    items = [PPDbManager loadAllItemsOfEntity:entity withPredicate:predicate];
    return items;
}

+ (NSArray*) loadAllItemsOfEntity:(NSEntityDescription*)entity withPredicate:(NSPredicate*)predicate
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray* items = nil;
	
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
    
    if (predicate)
    {
        [request setPredicate:predicate];
    }
    
	items = [app.managedObjectContext executeFetchRequest:request error:nil];
	return items;
}

+ (void) removeObject:(NSManagedObject*)object
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[app.managedObjectContext deleteObject:object];
}

+ (void) save
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSError* error = nil;
    
	[app.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"save db error: %@", [error description]);
    }
}

+ (void) rollback
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[app.managedObjectContext undo];
}

@end
