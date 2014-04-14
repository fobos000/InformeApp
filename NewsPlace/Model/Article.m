//
//  Article.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/2/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "Article.h"
#import "NSManagedObject+JSONMapping.h"
#import "NSManagedObject+Fetching.h"
#import "NPAAPIClient.h"
#import "NPAppDelegate.h"
#import "ArticleSource.h"

@implementation Article

@dynamic content;
@dynamic date;
@dynamic serverId;
@dynamic sourceLink;
@dynamic title;
@dynamic sourceId;
@dynamic categoryId;

+ (NSString *)idProperty
{
    return NSStringFromSelector(@selector(serverId));
}

+ (NSString *)keyForAttributeName:(NSString *)attributeName
{
    static NSDictionary *sAttributeKeypaths = nil;
    if (!sAttributeKeypaths) {
        sAttributeKeypaths = @{@"serverId": @"id",
                               @"sourceLink": @"source",
                               @"sourceId": @"pattern_id"};
    }
    return [sAttributeKeypaths valueForKey:attributeName];
}

- (NSString *)sourceName
{
    ArticleSource *source = [ArticleSource objectWithId:self.sourceId
                                              inContext:self.managedObjectContext];
    return source.name;
}

- (NSString *)formattedDate
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    }
    return [formatter stringFromDate:self.date];
}

@end
