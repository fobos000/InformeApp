//
//  NPAppDelegate.m
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPAppDelegate.h"
#import "NPHighlightsViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "NPSideMenuViewController.h"

@implementation NPAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupPrepopulatedDB];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    UINavigationController *leftSideMenuNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuNavigationController];
    [container setCenterViewController:navigationController];
    
    NPHighlightsViewController *hvc = (NPHighlightsViewController *)navigationController.topViewController;
    hvc.context = self.managedObjectContext;
    
    NPSideMenuViewController *sideMenu = leftSideMenuNavigationController.viewControllers.firstObject;
    sideMenu.context = self.managedObjectContext;
    sideMenu.delegate = hvc;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]
                                 initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewsPlace" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self storeURL];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Prepopulated DB

- (void)setupPrepopulatedDB
{
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString* bundleVersion = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *seedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SeedVersion"];
    if (![seedVersion isEqualToString:bundleVersion]) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError *error;
        
        if([fileManager fileExistsAtPath:self.storeURL.path]) {
            NSURL *storeDirectory = [self.storeURL URLByDeletingLastPathComponent];
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:storeDirectory
                                                  includingPropertiesForKeys:nil
                                                                     options:0
                                                                errorHandler:NULL];
            NSString *storeName = [self.storeURL.lastPathComponent stringByDeletingPathExtension];
            for (NSURL *url in enumerator) {
                if (![url.lastPathComponent hasPrefix:storeName]) continue;
                [fileManager removeItemAtURL:url error:&error];
            }
            // handle error
        }
        
        NSString* bundleDbPath = [[NSBundle mainBundle] pathForResource:@"NewsPlace" ofType:@"sqlite"];
        [fileManager copyItemAtPath:bundleDbPath toPath:self.storeURL.path error:&error];
        
        NSString* bundleDbPathShm = [[NSBundle mainBundle] pathForResource:@"NewsPlace" ofType:@"sqlite-shm"];
        [fileManager copyItemAtPath:bundleDbPathShm toPath:self.storeShmURL.path error:&error];
        
        NSString* bundleDbPathWal = [[NSBundle mainBundle] pathForResource:@"NewsPlace" ofType:@"sqlite-wal"];
        [fileManager copyItemAtPath:bundleDbPathWal toPath:self.storeWalURL.path error:&error];
    }
    
    // ... after the import succeeded
    [[NSUserDefaults standardUserDefaults] setObject:bundleVersion forKey:@"SeedVersion"];
}

#pragma mark - Store paths

- (NSURL *)storeShmURL
{
    return [[self storeDirectory] URLByAppendingPathComponent:@"NewsPlace.sqlite-shm"];
}

- (NSURL *)storeWalURL
{
    return [[self storeDirectory] URLByAppendingPathComponent:@"NewsPlace.sqlite-wal"];
}


- (NSURL *)storeURL
{
    return [[self storeDirectory] URLByAppendingPathComponent:@"NewsPlace.sqlite"];
}

- (NSURL *)storeDirectory
{
    return [self applicationDocumentsDirectory];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
