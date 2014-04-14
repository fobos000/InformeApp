//
//  NPDateParser.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/4/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPDateParser : NSObject

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;

@end
