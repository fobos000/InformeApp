//
//  Article.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/2/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSString * sourceLink;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber *sourceId;
@property (nonatomic, retain) NSNumber *categoryId;

- (NSString *)sourceName;
- (NSString *)formattedDate;

@end
