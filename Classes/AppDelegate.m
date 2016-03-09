//
//  AppDelegate.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "MBProgressHUD.h"
#import "Model.h"
#import "UINavigationControllerEx.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Protocol.h"
#import "PPDbManager.h"
#import "DBUser+Methods.h"
#import "DBGroup+Methods.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GAI.h"
#import "APIKey.h"

typedef void(^OnAlertClosedBlock)(NSUInteger clickedButton);

@interface AppDelegate()
{
	OnAlertClosedBlock _alertClosedBlock;
}

@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(UIViewController*)controllerWithName:(NSString*)name fromStoryboard:(NSString*)storyboard
{
	UIStoryboard* sb = [UIStoryboard storyboardWithName:storyboard bundle:[Model sharedInstance].settings.bundle];
	return [sb instantiateViewControllerWithIdentifier:name];
}

-(NSString*)localizedStringForKey:(NSString*)string
{
	return [[Model sharedInstance].settings.bundle localizedStringForKey:string value:nil table:@"LocalizableStrings"];
}

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload
{
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    for(UIViewController* vc in [navigationController viewControllers])
	{
        if ([vc conformsToProtocol:@protocol(TrafficProtocol)])
        {
            [vc performSelector:@selector(trafficChanged:friendlyUpload:) withObject:friendlyDownload withObject:friendlyUpload];
        }
	}

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initDatabase];
    //self.locationManager = [[CLLocationManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout:) name:@"logout" object:nil];
    
    // copy settings plist to document folder
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* settingsPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    
    if ([fileManager fileExistsAtPath:settingsPath] == NO)
    {
        NSString* resourcePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        [fileManager copyItemAtPath:resourcePath toPath:settingsPath error:&error];
    }
	
	LoginVC* loginVC = (LoginVC*)[self controllerWithName:@"LoginVC" fromStoryboard:@"AuthorizationStoryboard"];

	UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
	//[navigationVC setNavigationBarHidden:YES];
    
    NSMutableDictionary* titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"Helvetica-Bold" size:17] forKey:UITextAttributeFont];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
	[navigationVC setViewControllers:@[loginVC]];
    
    [GMSServices provideAPIKey:APIKey];
    
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].debug = YES;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41329292-1"];

	self.window.rootViewController = navigationVC;
	[self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)onLogout:(NSNotification*)notification
{
	NSLog(@"!!! logout !!!");
	LoginVC* loginVC = (LoginVC*)[self controllerWithName:@"LoginVC" fromStoryboard:@"AuthorizationStoryboard"];
	
	UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
	[navigationVC setNavigationBarHidden:YES];
	[navigationVC setViewControllers:@[loginVC]];
	
	self.window.rootViewController = navigationVC;
	[self.window makeKeyAndVisible];
	//[self showAlertWithMessage:@"Timeout is expired. Application has logged out"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[Model sharedInstance].settings save];
	[[Model sharedInstance].credentials save];
    
    UINavigationController* nc = (UINavigationController*)self.window.rootViewController;
    UIViewController* vc = nc.visibleViewController;
    if ([vc respondsToSelector:@selector(willBackgroundMode)])
    {
        [vc performSelector:@selector(willBackgroundMode)];
    }
	
	[Model sharedInstance].backgroundModeActive = YES;
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"AppDelegate" withAction:@"applicationDidEnterBackground" withLabel:@"to_background" withValue:nil];
    
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //!!! NSInteger unreadCount = [[[Model sharedInstance].myMessages unreadMessages] count];
    //!!! [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	//!!! [[NSNotificationCenter defaultCenter] removeObserver:self];
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UINavigationController* nc = (UINavigationController*)self.window.rootViewController;
    UIViewController* vc = nc.visibleViewController;
    if ([vc respondsToSelector:@selector(willForegroundMode)])
    {
        [vc performSelector:@selector(willForegroundMode)];
    }
    
	[FBSession.activeSession handleDidBecomeActive];
	[Model sharedInstance].backgroundModeActive = NO;
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"AppDelegate" withAction:@"applicationDidBecomeActive" withLabel:@"to_foreground" withValue:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark -
#pragma mark Core Data stack

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) initDatabase
{
    [self managedObjectContext];
    [self managedObjectModel];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil)
	{
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
	{
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        
		// REC: Add undo manager to context.
		NSUndoManager* undoManager = [[NSUndoManager alloc] init];
		[self.managedObjectContext setUndoManager:undoManager];
		
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel != nil)
	{
        return _managedObjectModel;
    }
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"db" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
	{
        return _persistentStoreCoordinator;
    }
    
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"db.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end

@implementation AppDelegate(Notifications)

-(void)showActivity
{
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
	hud.minShowTime = 0.2f;
}

-(void)hideActivity
{
	[MBProgressHUD hideAllHUDsForView:self.window animated:YES];
}

-(void)showAlertWithMessage:(NSString*)message
{
	[DELEGATE hideActivity];
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message
												   delegate:nil cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

-(void)showAlertWithBlock:(void(^)(NSUInteger clickedButton))block message:(NSString*)message buttons:(NSString*)buttons, ...
{
	[DELEGATE hideActivity];
	_alertClosedBlock = block;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message
												   delegate:self cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	va_list args;
	va_start(args, buttons);
	
	NSUInteger index = 0;
	NSString* cancelButtonTitle = nil;
	for (NSString* arg = buttons; arg != nil; arg = va_arg(args, NSString*), ++index)
    {
		if(index == 0)
		{
			cancelButtonTitle = arg;
			continue;
		}
		else
		{
			[alert addButtonWithTitle:arg];
		}
    }
	va_end(args);
	
	[alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	_alertClosedBlock(buttonIndex);
}

@end

@implementation AppDelegate(FileManagement)

-(NSString*)documentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end