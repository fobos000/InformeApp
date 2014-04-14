//
//  NSManagedObject+JSONMapping.h
//  ViewQ
//
//  Created by Ostap Horbach on 2/15/13.
//  Copyright (c) 2013 Ostap Horbach. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString *const VQDateFormat;

@interface NSManagedObject (JSONMapping)

- (void)setAttributesWithDictionary:(NSDictionary *)keyedValues;

+ (NSString *)keyForAttributeName:(NSString *)attributeName;

@end
