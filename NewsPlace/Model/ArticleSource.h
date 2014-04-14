//
//  ArticleSource.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArticleSource : NSManagedObject

@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSString * name;

@end
