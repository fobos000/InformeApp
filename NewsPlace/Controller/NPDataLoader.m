//
//  NPDataLoader.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/3/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPDataLoader.h"
#import "Article.h"
#import "ArticleSource.h"
#import "ArticleCategory.h"

#import "NSManagedObject+JSONMapping.h"
#import "NSManagedObject+Fetching.h"
#import "NPAAPIClient.h"
#import "NPAppDelegate.h"

#define kUpdateInterval 5 * 60 // 5 minutes

@interface NPDataLoader ()

@property (nonatomic, readwrite) NSDate *lastUpdateDate;

@end

@implementation NPDataLoader

static NPDataLoader *sDataLoader = nil;

+ (NPDataLoader *)sharedInstance
{
    return sDataLoader;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDataLoader = [[NPDataLoader alloc] init];
    });
}

+ (NSManagedObjectContext *)managedObjectContext
{
    NPAppDelegate *appDelegate = (NPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+ (void)saveChanges
{
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", error);
        }
    }
}

+ (void)loadDataWithBlock:(void (^)(BOOL success))block
{
    [self loadSourcesWithBlock:^(BOOL success) {
        [self loadCategoriesWithBlock:^(BOOL success) {
            if (success) {
                [self loadArticlesWithBlock:block];
            }
        }];
    }];
}

+ (NSURLSessionDataTask *)loadArticlesWithBlock:(void (^)(BOOL success))block
{
    NSNumber *maxId = [Article maxIdInContext:[self managedObjectContext]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (maxId) {
        [params setObject:maxId forKey:@"id"];
    }
    
    return [[NPAAPIClient sharedClient] GET:@"by_id.json"
                          parameters:params
                             success:^(NSURLSessionDataTask *task, id JSON) {
        NSArray *articlesFromResponse = JSON;
        for (NSDictionary *attributes in articlesFromResponse) {
            id articleId = [attributes valueForKey:@"id"];
            Article *article = [Article findOrCreateObjectWithId:articleId
                                                       inContext:self.managedObjectContext];
            [article setAttributesWithDictionary:attributes];
            id categories = [attributes valueForKey:@"categories"];
            if ([categories isKindOfClass:[NSArray class]]) {
                article.categoryId = [categories firstObject];
            }
        }
        [self saveChanges];
        
        // Save last update time
        sDataLoader.lastUpdateDate = [NSDate date];
                                 
        if (block) {
            block(YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        if (block) {
            block(NO);
        }
    }];
}

+ (NSURLSessionDataTask *)loadSourcesWithBlock:(void (^)(BOOL success))block
{
    return [[NPAAPIClient sharedClient] GET:@"patterns.json"
                          parameters:nil
                             success:^(NSURLSessionDataTask *task, id JSON) {
        NSArray *sourcesFromResponse = JSON;
        for (NSDictionary *attributes in sourcesFromResponse) {
            id sourceId = [attributes valueForKey:@"id"];
            ArticleSource *source = [ArticleSource findOrCreateObjectWithId:sourceId
                                                                         inContext:self.managedObjectContext];
            [source setAttributesWithDictionary:attributes];
        }
        [self saveChanges];
         if (block) {
             block(YES);
         }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        if (block) {
            block(NO);
        }
    }];
}

+ (NSURLSessionDataTask *)loadCategoriesWithBlock:(void (^)(BOOL success))block
{
    return [[NPAAPIClient sharedClient] GET:@"categories.json"
                                 parameters:nil
                                    success:^(NSURLSessionDataTask *task, id JSON) {
        NSArray *sourcesFromResponse = JSON;
        for (NSDictionary *attributes in sourcesFromResponse) {
            id sourceId = [attributes valueForKey:@"id"];
            ArticleCategory *category = [ArticleCategory findOrCreateObjectWithId:sourceId
                                                                        inContext:self.managedObjectContext];
            [category setAttributesWithDictionary:attributes];
        }
        [self saveChanges];
        if (block) {
            block(YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
        if (block) {
            block(NO);
        }
    }];
}

- (BOOL)needsUpdate
{
    if (!_lastUpdateDate) {
        return YES;
    }
    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:self.lastUpdateDate] > kUpdateInterval;
}

@end
