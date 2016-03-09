//
//  AppDelegate.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DBUser.h"
#import "DBGroup.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
{
    __strong NSManagedObjectContext* _managedObjectContext;
    __strong NSManagedObjectModel* _managedObjectModel;
    __strong NSPersistentStoreCoordinator* _persistentStoreCoordinator;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property(nonatomic, weak) DBUser* me;
@property (nonatomic, weak) DBGroup* currentGroup;
//@property (strong, nonatomic) CLLocationManager* locationManager;

-(UIViewController*)controllerWithName:(NSString*)name fromStoryboard:(NSString*)storyboard;
-(NSString*)localizedStringForKey:(NSString*)string;
- (void)onLogout:(NSNotification*)notification;

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload;

@end

@interface AppDelegate(Notifications)

-(void)showActivity;
-(void)hideActivity;
-(void)showAlertWithMessage:(NSString*)message;
-(void)showAlertWithBlock:(void(^)(NSUInteger clickedButton))block message:(NSString*)message buttons:(NSString*)buttons, ...;
@end

@interface AppDelegate(FileManagement)

-(NSString*)documentsDirectory;

@end
