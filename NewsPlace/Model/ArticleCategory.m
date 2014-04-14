//
//  Category.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/8/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "ArticleCategory.h"


@implementation ArticleCategory

@dynamic name;
@dynamic serverId;

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
