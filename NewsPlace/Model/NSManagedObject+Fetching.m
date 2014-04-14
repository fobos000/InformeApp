//
//  NSManagedObject+Fetching.m
//  ViewQ
//
//  Created by Ostap Horbach on 2/15/13.
//  Copyright (c) 2013 Ostap Horbach. All rights reserved.
//

#import "NSManagedObject+Fetching.h"

@implementation NSManagedObject (Fetching)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)allObjectsInContext:(NSManagedObjectContext *)context;
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        //handle errors
    }
    return results;
}

+ (NSArray *)objectsWithPredicate:(NSPredicate *)predicate
                  sortDescriptors:(NSArray *)sortDescriptors
                        inContext:(NSManagedObjectContext *)context
{
    __block NSArray *objectsWithPredicate = nil;
    
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        objectsWithPredicate = [context executeFetchRequest:request error:&error];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    return objectsWithPredicate;
}

+ (NSManagedObject *)objectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *objectWithPredicate = nil;
    
    objectWithPredicate = [[self objectsWithPredicate:predicate sortDescriptors:nil inContext:context] lastObject];
    
    return objectWithPredicate;
}

+ (NSManagedObject *)newObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[[self entityDescriptionInContext:context] name] inManagedObjectContext:context];
}

+ (NSManagedObject *)findOrCreateObjectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *objectWithPredicate = nil;
    
    objectWithPredicate = [self objectWithPredicate:predicate inContext:context];
    if (!objectWithPredicate) {
        objectWithPredicate = [self newObjectInContext:context];
    }
    
    return objectWithPredicate;
}

#pragma mark - Fetching by ID

+ (NSString *)idProperty
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (instancetype)objectWithId:(id)objectId inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *objectWithId = nil;
    
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"%K = %@", [self idProperty], objectId];
    objectWithId = [self objectWithPredicate:pr inContext:context];
    
    return objectWithId;
}

+ (instancetype)findOrCreateObjectWithId:(id)objectId inContext:(NSManagedObjectContext *)context
{
    NSManagedObject *objectWithId = nil;

    objectWithId = [self objectWithId:objectId inContext:context];
    if (!objectWithId) {
        objectWithId = [self newObjectInContext:context];
    }

    return objectWithId;
}

+ (id)maxIdInContext:(NSManagedObjectContext *)context
{
    id maxIdInContext = nil;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self idProperty] ascending:NO];
    NSArray *results = [self objectsWithPredicate:nil sortDescriptors:@[sortDescriptor] inContext:context];
    NSManagedObject *firstResult = results.firstObject;
    
    if (firstResult) {
        maxIdInContext = [firstResult valueForKey:[self idProperty]];
    }
    
    return maxIdInContext;
}

@end
