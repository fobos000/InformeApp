//
//  NPDataLoader.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/3/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPDataLoader : NSObject

@property (nonatomic, readonly) NSDate *lastUpdateDate;
@property (nonatomic, readonly) BOOL needsUpdate;

+ (void)loadDataWithBlock:(void (^)(BOOL success))block;
+ (NSURLSessionDataTask *)loadSourcesWithBlock:(void (^)(BOOL success))block;
+ (NSURLSessionDataTask *)loadArticlesWithBlock:(void (^)(BOOL success))block;
+ (NSURLSessionDataTask *)loadCategoriesWithBlock:(void (^)(BOOL success))block;

@end
