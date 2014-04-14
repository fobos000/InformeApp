//
//  NSManagedObject+Fetching.h
//  ViewQ
//
//  Created by Ostap Horbach on 2/15/13.
//  Copyright (c) 2013 Ostap Horbach. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Fetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allObjectsInContext:(NSManagedObjectContext *)context;
+ (NSArray *)objectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *)objectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *)newObjectInContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *)findOrCreateObjectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSString *)idProperty;
+ (instancetype)objectWithId:(id)objectId inContext:(NSManagedObjectContext *)context;
+ (instancetype)findOrCreateObjectWithId:(id)objectId inContext:(NSManagedObjectContext *)context;
+ (id)maxIdInContext:(NSManagedObjectContext *)context;

@end
