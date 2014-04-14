//
//  NPAppDelegate.h
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
