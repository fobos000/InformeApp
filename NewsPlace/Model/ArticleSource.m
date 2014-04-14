//
//  ArticleSource.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "ArticleSource.h"
#import "NSManagedObject+Fetching.h"
#import "NSManagedObject+JSONMapping.h"


@implementation ArticleSource

@dynamic serverId;
@dynamic name;

+ (NSString *)idProperty
{
    return NSStringFromSelector(@selector(serverId));
}

+ (NSString *)keyForAttributeName:(NSString *)attributeName
{
    static NSDictionary *sAttributeKeypaths = nil;
    if (!sAttributeKeypaths) {
        sAttributeKeypaths = @{@"serverId": @"id"};
    }
    return [sAttributeKeypaths valueForKey:attributeName];
}

@end
